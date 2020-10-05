//
//  PetImageView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct PetImageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var petStore: PetStore
    @EnvironmentObject var managePetStore: ManagePetStore
    @Environment(\.imageCache) var cache: ImageCache
    
    private var petUrl: String {
        managePetStore.state.selectedPet?.url ?? ""
    }
        
    private var pet: Pet? {
        petStore.state.fetchResult.filter({$0.url == petUrl}).first
    }
    
    private var petImage: some View {
        VStack {
            pet?.image(from: cache)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }

    private var favColor: Color {
        return pet?.isFavourite ?? false ? .accentColor : .gray
    }

    var body: some View {
        ZStack {
            petImage
            .onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
            }
            .overlay(Button(action: {
                self.toggleFavourite()
            }, label: { Image(systemName: "heart.fill")
                .font(.body)
                .foregroundColor(favColor)
                .padding()}).buttonStyle(BorderlessButtonStyle()),
                     alignment: .bottomTrailing)
        }
    }
    
    private func toggleFavourite() {
        guard let pet = pet else {
            return
        }
        let isFavourite = !pet.isFavourite
        var imageData: Data?
        if isFavourite {
            imageData = pet.uiImage(from: self.cache)?.jpegData(compressionQuality: 1.0)
        }
        managePetStore.send(.updatePet(pet, image: imageData, favourite: isFavourite, petState: petStore.state))
    }
}

struct PetImageView_Previews: PreviewProvider {
    static var previews: some View {
        return PetImageView()
            .environmentObject(PreviewSupport.petStoreMock)
            .environmentObject(PreviewSupport.managePetStoreMock)
            .environment(\.imageCache, PetApiMock().cache)
            .onAppear {
                PreviewSupport.petStoreMock.send(.fetch(page: 1))
                PreviewSupport.managePetStoreMock.send(.select(pet: Pet("https://dog1.jpg", isFavourite: false)))
            }
    }
}
