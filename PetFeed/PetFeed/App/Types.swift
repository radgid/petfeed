//
//  AppState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

typealias PetStore = Store<PetState, PetAction, PetEnvironment>
typealias FavouritePetStore = Store<FavouritePetState, FavouritePetAction, PetEnvironment>
typealias ManagePetStore = Store<ManagePetState, ManagePetAction, PetEnvironment>
