//
//  PetRequest.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

enum PetType: String {
    case shibes = "shibes"
    case cats = "cats"
    case birds = "birds"
}

protocol PetRequest: Encodable {
    var count: Int {get}
    var urls: Bool? {get}
    var httpsUrls: Bool? {get}
    func api() -> String
}

struct ShibeRequest: PetRequest, Encodable {
    let count: Int
    let urls: Bool? = true
    let httpsUrls: Bool? = true
    func api() -> String {
        return PetType.shibes.rawValue
    }
}

struct CatRequest: PetRequest, Encodable {
    let count: Int
    let urls: Bool? = true
    let httpsUrls: Bool? = true
    func api() -> String {
        return PetType.cats.rawValue
    }
}

struct BirdRequest: PetRequest, Encodable {
    let count: Int
    let urls: Bool? = true
    let httpsUrls: Bool? = true
    func api() -> String {
        return PetType.birds.rawValue
    }
}
