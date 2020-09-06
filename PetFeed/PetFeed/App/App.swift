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
    static let pageSize = 100
    //TODO: Paging to be considered - at the moment the Mock Pet server does not preserve any kind of sort so paging makes only sence
    // in terms of loading batches of data as oposed to sorted data
}

/// Settings used throughout the App
struct Settings {
    //    static let store = Store(initialState: .init(),
    //                             reducer: appReducer,
    //                             environment: PetEnvironment(service: PetApi()))
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
    var fetchFavouriteResult: [DisplayablePet] = []
    var updatedPet: Pet?
}

/// App Actions
enum AppAction {
    case fetch(page: Int)
    case fetchFavourite(page: Int)
    case setFetchResult(pets: [Pet])
    case setFetchFavouriteResult(pets: [DisplayablePet])
    case updatePet(_ pet: Pet, image: Data? = nil, favourite: Bool)
    case setUpdatedPet(pet: Pet)
}

/// Reducer to get the next action from the current state and current action
func appReducer(state: inout AppState,
                action: AppAction,
                environment: PetEnvironment) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setFetchResult(pets):
        state.fetchResult = pets
    case let .setFetchFavouriteResult(pets):
        state.fetchFavouriteResult = pets
    case let .setUpdatedPet(pet):
        state.updatedPet = pet
    case let .fetch(page):
        let request = PetRequest(count: Constants.pageSize * page)
        return environment.service
            .fetch(request)
            .replaceError(with: [])
            .map {AppAction.setFetchResult(pets: $0)}
            .eraseToAnyPublisher()
    case let .fetchFavourite(page):
        return environment.service
            .fetchFavourites(page: page)
            .replaceError(with: [])
            .map {AppAction.setFetchFavouriteResult(pets: $0)}
            .eraseToAnyPublisher()
    case let .updatePet(pet, image, favourite):
        return environment.service
            .setPet(pet, image: image, favourite: favourite)
            .replaceError(with: pet)
            .map { AppAction.setUpdatedPet(pet: $0)}
            .eraseToAnyPublisher()
    }

    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppState, AppAction, PetEnvironment>
