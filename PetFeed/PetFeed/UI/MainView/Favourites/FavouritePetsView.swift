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
            List {
                ForEach(Array(pets.enumerated()), id: \.element) { _, pet in
                    VStack {
                        FavouritePetRow(pet: pet).onTapGesture {
                            Log.user().info(message: "pressed Dog detail")
                        }
                    }
                }
            }
        }.onReceive(self.store.$state) { state in
            self.pets = state.fetchFavouriteResult
        }
    }
}

struct FavouritePetsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetsView()
    }
}
