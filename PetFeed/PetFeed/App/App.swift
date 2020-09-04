//
//  AppState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

/// Constants used throughout the App
struct Constants {
    static let pageSize = 5
}

/// Settings used throughout the App
struct Settings {
    static let store = Store(initialState: .init(),
                             reducer: appReducer,
                             environment: PetEnvironment(service: PetApi()))
    static let storeMock = Store(initialState: .init(),
                                reducer: appReducer,
                                environment: PetEnvironment(service: PetApiMock()))
}

struct PetEnvironment {
    let service: PetRepository
}

/// Global AppState
struct AppState {
    var fetchResult: [Pet] = []
}

/// App Actions
enum AppAction {
    case fetch(page: Int)
    case setFetchResult(pets: [Pet])
    case setPet(_ pet: Pet, favourite: Bool)
}

/// Reducer to get the next action from the current state and current action
func appReducer(state: inout AppState,
                action: AppAction,
                environment: PetEnvironment) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setFetchResult(pets):
        state.fetchResult = pets
    case let .fetch(page):
        let request = PetRequest(count: Constants.pageSize * page)
        return environment.service
            .fetch(request)
            .replaceError(with: [])
            .map{AppAction.setFetchResult(pets: $0)}
            .eraseToAnyPublisher()
    case let .setPet(pet, favourite):
        break
    }
    
    
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppState, AppAction, PetEnvironment>