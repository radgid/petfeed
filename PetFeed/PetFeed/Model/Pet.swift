//
//  Pet.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

struct Pet: Identifiable, Hashable, Codable {
    let id: String = UUID().uuidString
    let url: String

    init(_ url: String) {
        self.url = url
    }
}
