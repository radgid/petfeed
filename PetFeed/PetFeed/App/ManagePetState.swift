//
//  ManagePetState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 02/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

/// Global AppState
final class ManagePetState {
    var updatedPet: Pet?
    var selectedPet: Pet?
}

/// App Actions
enum ManagePetAction {
    case clear
    case updatePet(_ pet: Pet,
                   image: Data? = nil,
                   favourite: Bool,
                   petState: PetState)
    case setUpdatedPet(pet: Pet, petState: PetState)
    case select(pet: Pet)
    case setSelectedPet(pet: Pet)
}

/// Reducer to get the next action from the current state and current action
func managePetReducer(state: inout ManagePetState,
                action: ManagePetAction,
                environment: PetEnvironment) -> AnyPublisher<ManagePetAction, Never> {
    switch action {
    case .clear:
        state.updatedPet = nil
        state.selectedPet = nil
    case let .updatePet(pet, image, favourite, petState):
        return environment.localService
            .setPet(pet, image: image, favourite: favourite)
            .replaceError(with: pet)
            .map { ManagePetAction.setUpdatedPet(pet: $0, petState: petState)}
            .eraseToAnyPublisher()
    case let .setUpdatedPet(pet, petState):
        state.updatedPet = pet
        var petState = petState
        _ = petReducer(state: &petState, action: .updatedPet(pet: pet), environment: environment)
    case let .select(pet):
        return environment.localService
            .selectPet(pet)
            .replaceError(with: pet)
            .map { ManagePetAction.setSelectedPet(pet: $0)}
            .eraseToAnyPublisher()
    case let .setSelectedPet(pet):
        state.selectedPet = pet
    }
    
    return Empty().eraseToAnyPublisher()
}
