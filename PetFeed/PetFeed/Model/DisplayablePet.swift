//
//  DisiplayablePet.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

struct DisplayablePet: Hashable, Identifiable {
    let id: String
    let image: Image
    
    init(id: String, image: Image) {
        self.id = id
        self.image = image
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
