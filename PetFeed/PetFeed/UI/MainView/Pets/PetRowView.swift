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

    @State var asyncImage: AsyncImage<Image>?
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                    asyncImage
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
                .background(Color(.systemFill))
                .cornerRadius(8)
        }.onReceive(self.store.state.$updatedPet) { updatedPet in
            if let updatedPet = updatedPet,
                updatedPet.url == self.pet.url {
                    self.pet = updatedPet
            }
        }.onReceive(NotificationCenter.default.publisher(for:
            Notification.Name.didDismissPetDetail)) { _ in
                DispatchQueue.main.async {
                    self.asyncImage?.refreshIfNeeded()
                }
        }.onAppear {
            self.asyncImage =
                AsyncImage(url: URL(string: self.pet.url),
                           placeholder: Image(systemName: "hourglass"),
                           cache: self.cache,
                           service: self.store.environment.service)
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

struct PetRowView_Previews: PreviewProvider {
    static var previews: some View {
        PetRow(pet: Pet("dog1.jpg", isFavourite: false))
            .environmentObject(Settings.storeMock)
    }
}
