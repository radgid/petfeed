//
//  FavouritePetsView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct FavouritePetsView: View {
    @State private var pets: [DisplayablePet] = []
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        
        VStack {
            if pets.isEmpty {
                NoDataFoundView()
            } else {
                ScrollView(.vertical) {
                    ForEach(pets, id: \.id) { pet in
                        FavouritePetRow(pet: pet)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }
                }.animation(.default)
            }
        }.onReceive(self.store.state.$fetchFavouriteResult) { fetchFavouriteResult in
            self.pets = fetchFavouriteResult
        }
    }
}

struct FavouritePetsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetsView()
            .environmentObject(Settings.storeMock)
            .onAppear {
                Settings.storeMock.send(.fetchFavourite(page: 1))
        }.environment(\.colorScheme, .dark)
    }
}
