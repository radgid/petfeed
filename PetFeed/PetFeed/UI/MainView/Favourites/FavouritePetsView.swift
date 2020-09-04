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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FavouritePetsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePetsView(pets: [DisplayablePet(id: "test",
                                                image: PetApiMock().petImage())] )
    }
}
