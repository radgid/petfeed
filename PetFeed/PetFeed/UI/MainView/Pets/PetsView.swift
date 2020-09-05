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
    let pets: [Pet]
    @State private var isPresented: Bool = false
    @State private var selection: Pet?
    
    var body: some View {
        VStack{
            List {
                ForEach(Array(pets.enumerated()), id: \.element) { idx, pet in
                    VStack {
                        PetRow(pet: pet).onTapGesture {
                            Log.user().info(message: "pressed Dog detail")
                            self.selection = pet
                            self.isPresented.toggle()
                            }
                        .sheet(isPresented: self.$isPresented) {
                            if self.selection != nil {
                                PetImageView(petImage: self.selection!.image(from: self.cache), pet: self.selection!)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }
    }
}

