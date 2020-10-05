//
//  FavouritePetState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 02/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

final class FavouritePetState: ObservableObject {
    @Published var fetchResult: [DisplayablePet] = []
    @Published var failure: PetFailure?
}
/// App Actions
enum FavouritePetAction {
    case fetch(page: Int)
    case setFetchResult(pets: [DisplayablePet])
    case setFailure(_ failure: PetFailure)
    case removePet(petId: String)
}

func favouritePetReducer(state: inout FavouritePetState,
                         action: FavouritePetAction,
                         environment: PetEnvironment) -> AnyPublisher<FavouritePetAction, Never> {
    switch action {
        case let .fetch(page):
            return environment.localService
                .fetchFavourites(page: page)
                .map {FavouritePetAction.setFetchResult(pets: $0)}
                .catch{failure -> AnyPublisher<FavouritePetAction, Never> in
                    .just( FavouritePetAction.setFailure(failure))
                }.eraseToAnyPublisher()
        case let .setFetchResult(pets):
            state.fetchResult = pets
        case let .setFailure(failure):
            state.failure = failure
        case let .removePet(petId):
            if let row = state.fetchResult.firstIndex(where: {$0.id == petId}) {
                state.fetchResult.remove(at: row)
            }
    }
    
    return Empty().eraseToAnyPublisher()
}
