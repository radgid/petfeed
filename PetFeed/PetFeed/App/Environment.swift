//
//  Environment.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 05/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

struct PetEnvironment {
    let networkService: NetworkPetRepository
    let localService: LocalPetRepository
}
