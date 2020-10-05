//
//  FavouritePetsView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct FavouritePetsView: View {
    
    @EnvironmentObject var favPetStore: FavouritePetStore
    
    private var pets: [DisplayablePet]  {
        favPetStore.state.fetchResult
    }
    
    var body: some View {
        VStack {
            if pets.isEmpty {
                NoDataFoundView()
            } else {
                ScrollView(.vertical) {
                    ForEach(pets, id: \.id) { pet in
                        FavouritePetRow(petId: pet.id)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }
                }.animation(.default)
            }
        }.onAppear {
            self.fetchFavourite()
        }
    }
    
    // MARK: - Actions
    private func fetchFavourite() {
        favPetStore.send(.fetch(page:1))
    }
}

struct FavouritePetsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetsView()
            .environmentObject(PreviewSupport.favouritePetStoreMock)
            .onAppear {
                PreviewSupport.favouritePetStoreMock.send(.fetch(page: 1))
        }.environment(\.colorScheme, .dark)
    }
}
