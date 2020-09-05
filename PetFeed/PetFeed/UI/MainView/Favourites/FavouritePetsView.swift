//
//  FavouritePetsView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct FavouritePetsView: View {
    let pets: [DisplayablePet]
    
    var body: some View {
        VStack{
            List {
                ForEach(Array(pets.enumerated()), id: \.element) { idx, pet in
                    VStack {
                        FavouritePetRow(pet: pet).onTapGesture {
                            Log.user().info(message: "pressed Dog detail")
//                            self.selection = pet
//                            self.isPresented.toggle()
                            }
                    }
                }
            }
        }
    }
}

struct FavouritePetsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetsView(pets: [DisplayablePet(id: "test",
                                                image: PetApiMock().petImage())] )
    }
}
