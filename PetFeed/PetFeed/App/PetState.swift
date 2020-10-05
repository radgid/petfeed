//
//  PetState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 02/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

final class PetState: ObservableObject {
    @Published var fetchResult: [Pet] = []
    @Published var failure: PetFailure?
}
/// App Actions
enum PetAction {
    case fetch(page: Int)
    case setFetchResult(pets: [Pet])
    case setFailure(_ failure: PetFailure)
    case updatedPet(pet: Pet)
}

func petReducer(state: inout PetState,
                action: PetAction,
                environment: PetEnvironment) -> AnyPublisher<PetAction, Never> {
    switch action {
    case let .fetch(page):
        let request = ShibeRequest(count: Constants.pageSize * page)
        return environment.networkService
            .fetch(request)
            .map {PetAction.setFetchResult(pets: $0)}
            .catch{failure -> AnyPublisher<PetAction, Never> in
                .just( PetAction.setFailure(failure))
        }.eraseToAnyPublisher()
    case let .setFetchResult(pets):
        state.fetchResult = pets
    case let .setFailure(failure):
        state.failure = failure
    case let .updatedPet(pet):
        if let row = state.fetchResult.firstIndex(where: {$0.url == pet.url}) {
            state.fetchResult[row] = pet
        }
    }
    
    return Empty().eraseToAnyPublisher()
}
