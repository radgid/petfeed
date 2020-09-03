//
//  Pet.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

public struct Pet: Identifiable, Codable {
    public let id: String = UUID().uuidString
    public let url: String
    
    public init(_ url: String) {
        self.url = url
    }
}
