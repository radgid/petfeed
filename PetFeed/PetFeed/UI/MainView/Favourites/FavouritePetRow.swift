//
//  FavouritePetRow.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 05/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct FavouritePetRow: View {
    
    @EnvironmentObject var petStore: PetStore
    @EnvironmentObject var managePetStore: ManagePetStore
    @EnvironmentObject var favPetStore: FavouritePetStore
    
    let petId: String
    
    private var pet: DisplayablePet {
        favPetStore.state.fetchResult.filter({$0.id == petId}).first ?? DisplayablePet(id: "",
                                                                                       image: Image.init(systemName: "hourglass"))
    }
    private var favImage: some View {
        Image(systemName: "heart.fill")
            .font(.body)
            .foregroundColor(.accentColor)
            .padding()
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            pet.image.resizable()
                .modifier(PetImageModifier())
                .modifier(BackgroundShadow())
            Spacer()
        }.overlay(Button(action: {
            self.toggleFavourite()
        }, label: {favImage})
            .buttonStyle(BorderlessButtonStyle()), alignment: .bottomTrailing)
            .background(Color(.systemFill))
            .cornerRadius(8)
    }

    // MARK: - Actions
    private func toggleFavourite() {
        managePetStore.send(.updatePet(Pet(pet.id, isFavourite: true),
                                       favourite: false,
                                       petState: petStore.state))
        favPetStore.send(.removePet(petId: pet.id))
    }
}

struct FavouritePetRowView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetRow(petId: "https://dog1.jpg")
            .onAppear {
                PreviewSupport.favouritePetStoreMock.send(.fetch(page: 1))
            }
            .environment(\.colorScheme, .dark)
            .environmentObject(PreviewSupport.petStoreMock)
            .environmentObject(PreviewSupport.managePetStoreMock)
            .environmentObject(PreviewSupport.favouritePetStoreMock)
    }
}
