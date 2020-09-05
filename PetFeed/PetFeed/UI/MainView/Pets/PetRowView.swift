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
    let pet: Pet
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var store: AppStore
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            AsyncImage(url: URL(string: pet.url),
                       placeholder: Image(systemName: "hourglass").font(.title),
                       cache: self.cache,
                service: store.environment.service)
                .frame(height: 180)
                .padding()
                .shadow(color: Color.white.opacity(0.9), radius: 10, x: -10, y: -10)
                .shadow(color: Color.gray.opacity(0.5), radius: 14, x: 14, y: 14)
            Spacer()
        }.overlay(Button(action: {
            Log.user().info(message: "pressed Favourite")
        }, label: { Image(systemName: "heart.fill")
            .font(.body)
            .padding()}).buttonStyle(BorderlessButtonStyle())
            ,alignment: .bottomTrailing)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}
