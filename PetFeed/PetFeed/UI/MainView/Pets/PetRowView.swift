//
//  PetRowView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

struct PetRow: View {
    
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var petStore: PetStore
    @EnvironmentObject var managePetStore: ManagePetStore
    let petId: String
    
    private var pet: Pet? {
        petStore.state.fetchResult.filter({$0.id == petId}).first
    }
    
    @State var asyncImage: AsyncImage<Image>?
    
    private var favColor: Color {
        return pet?.isFavourite ?? false ? .accentColor : .gray
    }
    
    private var favButton: some View {
        Button(action: {
            self.toggleFavourite()
        }, label: {
            Image(systemName: "heart.fill")
            .font(.body)
            .foregroundColor(favColor)
            .padding()})
            .buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                    asyncImage
                    .frame(height: 180)
                    .padding()
                    .modifier(BackgroundShadow())
                Spacer()
            }.overlay( favButton , alignment: .bottomTrailing)
                .background(Color(.systemFill))
                .cornerRadius(8)
        }.onReceive(NotificationCenter.default.publisher(for:
            Notification.Name.didDismissPetDetail)) { _ in
                DispatchQueue.main.async {
                    self.asyncImage?.refreshIfNeeded()
                }
        }.onAppear {
            self.asyncImage =
                AsyncImage<Image>(url: URL(string: self.pet?.url ?? ""),
                           placeholder: Image(systemName: "hourglass"),
                           cache: self.cache,
                           service: self.petStore.environment.networkService)
        }
    }

    // MARK: - Actions
    private func toggleFavourite() {
        guard let pet = pet else {return}
        let isFavourite = !pet.isFavourite
        var imageData: Data?
        if isFavourite {
            imageData = pet.uiImage(from: self.cache)?.jpegData(compressionQuality: 1.0)
        }
        managePetStore.send(.updatePet(pet, image: imageData, favourite: !pet.isFavourite, petState: petStore.state))
    }
}

struct PetRowView_Previews: PreviewProvider {
    static var previews: some View {
        PetRow(petId: PreviewSupport.petStoreMock.state.fetchResult.first?.id ?? "")
            .environment(\.imageCache, PetApiMock().cache)
            .environmentObject(PreviewSupport.petStoreMock)
            .environmentObject(PreviewSupport.managePetStoreMock)
            .onAppear {
                PreviewSupport.petStoreMock.send(.fetch(page: 1))
            }
    }
}
