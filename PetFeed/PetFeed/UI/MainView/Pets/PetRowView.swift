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
    @State var pet: Pet
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var store: AppStore

    private var favColor: Color {
        return pet.isFavourite ? .accentColor : .gray
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                AsyncImage(url: URL(string: pet.url),
                           placeholder: Image(systemName: "hourglass").font(.title),
                           cache: self.cache,
                           service: store.environment.service)
                    .frame(height: 180)
                    .padding()
                    .modifier(BackgroundShadow())
                Spacer()
            }.overlay(Button(action: {
                self.toggleFavourite()
            }, label: { Image(systemName: "heart.fill")
                .font(.body)
                .foregroundColor(favColor)
                .padding()})
                .buttonStyle(BorderlessButtonStyle()), alignment: .bottomTrailing)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }.onReceive(self.store.$state) { state in
            if let updatedPet = state.updatedPet,
                updatedPet.url == self.pet.url {
                    self.pet = updatedPet
            }
        }
    }

    // MARK: - Actions
    private func toggleFavourite() {
        let isFavourite = !pet.isFavourite
        var imageData: Data?
        if isFavourite {
            imageData = pet.uiImage(from: self.cache)?.jpegData(compressionQuality: 1.0)
        }
        store.send(.updatePet(pet, image: imageData, favourite: !pet.isFavourite))
    }
}
