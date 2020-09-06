//
//  PetsView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

struct PetsView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var store: AppStore
    @State private var pets: [Pet] = []
    @State private var isPresented: Bool = false
    @State private var selection: Pet?

    var body: some View {
        VStack {
            List {
                ForEach(Array(pets.enumerated()), id: \.element) { _, pet in
                    VStack {
                        PetRow(pet: pet).onTapGesture {
                            self.selection = pet
                            self.isPresented.toggle()
                            }
                        .sheet(isPresented: self.$isPresented) {
                            //TODO: show the backdrop to soften the popup appearance
                            if self.selection != nil {
                                PetImageView(petImage: self.selection!.image(from: self.cache), pet: self.selection!)
                                    .environmentObject(self.store)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }.onReceive(self.store.$state) { state in
            self.pets = state.fetchResult
        }
    }
}
