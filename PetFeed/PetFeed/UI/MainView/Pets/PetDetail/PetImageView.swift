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
    @EnvironmentObject var store: AppStore
    @Environment(\.imageCache) var cache: ImageCache
        
    @State var pet: Pet?
    
    private var petImage: some View {
        pet?.image(from: cache)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private var favColor: Color {
        return pet?.isFavourite ?? false ? .accentColor : .gray
    }

    var body: some View {
        ZStack {
            VStack {
                petImage
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
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
        }.onAppear {
            self.pet = self.store.state.selectedPet
        }
        .onReceive(self.store.state.$selectedPet) { selectedPet in
            self.pet = selectedPet
        }
        .onReceive(self.store.state.$updatedPet) { updatedPet in
            if let updatedPet = updatedPet,
                updatedPet.url == self.pet?.url {
                    self.pet = updatedPet
            }
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
        store.send(.updatePet(pet, image: imageData, favourite: !pet.isFavourite))
    }
}

struct PetImageView_Previews: PreviewProvider {
    static var previews: some View {
        return PetImageView()
            .environmentObject(Settings.storeMock)
            .onAppear {
                Settings.storeMock.send(.select(pet: Pet("dog1.jpg", isFavourite: false)))
            }
    }
}
