//
//  PreviewSupport.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
/// PreviewSupport. used throughout the View Previews and tests
struct PreviewSupport {
    static let petStoreMock = Store(initialState: .init(),
                                 reducer: petReducer,
                                 environment: PetEnvironment(networkService: PetApiMock(),
                                                             localService: PetApiMock()))
    static let favouritePetStoreMock = Store(initialState: .init(),
                                 reducer: favouritePetReducer,
                                 environment: PetEnvironment(networkService: PetApiMock(),
                                                             localService: PetApiMock()))
    static let managePetStoreMock = Store(initialState: .init(),
                                 reducer: managePetReducer,
                                 environment: PetEnvironment(networkService: PetApiMock(),
                                                             localService: PetApiMock()))
}
