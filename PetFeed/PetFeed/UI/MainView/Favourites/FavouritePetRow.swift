//
//  FavouritePetRow.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 05/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct FavouritePetRow: View {
    @State var pet: DisplayablePet
    @EnvironmentObject var store: AppStore

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            pet.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 180)
                .padding()
                .modifier(BackgroundShadow())
            Spacer()
        }.overlay(Button(action: {
            self.toggleFavourite()
        }, label: { Image(systemName: "heart.fill")
            .font(.body)
            .foregroundColor(.accentColor)
            .padding()})
            .buttonStyle(BorderlessButtonStyle()), alignment: .bottomTrailing)
            .background(Color(.systemFill))
            .cornerRadius(8)
    }

    // MARK: - Actions
    private func toggleFavourite() {
        store.send(.updatePet(Pet(pet.id, isFavourite: true), favourite: false))
        store.send(.fetchFavourite(page: 1))
    }
}

struct FavouritePetRowView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetRow(pet: DisplayablePet(id: "test",
                                                image: PetApiMock().petImage()))
            .environment(\.colorScheme, .dark)
    }
}
