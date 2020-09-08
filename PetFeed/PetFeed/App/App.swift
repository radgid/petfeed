//
//  AppState.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics

/// Constants used throughout the App
struct Constants {
    static let pageSize = 50
    //TODO: Paging to be considered - at the moment the Mock Pet server does not preserve any kind of sort so paging makes only sence
    // in terms of loading batches of data as oposed to sorted data
    static let pullToRefreshOffset = CGFloat(100.0)
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
final class AppState: ObservableObject {
    @Published var fetchResult: [Pet] = []
    @Published var fetchFavouriteResult: [DisplayablePet] = []
    @Published var updatedPet: Pet?
    @Published var failure: PetFailure?
}

/// App Actions
enum AppAction {
    case fetch(page: Int)
    case fetchFavourite(page: Int)
    case setFetchResult(pets: [Pet])
    case setFetchFavouriteResult(pets: [DisplayablePet])
    case updatePet(_ pet: Pet, image: Data? = nil, favourite: Bool)
    case setUpdatedPet(pet: Pet)
    case setFailure(_ failure: PetFailure)
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
//        if let petIndex = state.fetchResult.firstIndex(where: {$0.url == pet.url}) {
//            state.fetchResult[petIndex] = pet
//        }
    case let .setFailure(failure):
        state.failure = failure
    case let .fetch(page):
        //TODO: Consider creating case specific reducers to reduce the complexity of Switch statement
        let request = ShibeRequest(count: Constants.pageSize * page)
        return environment.service
            .fetch(request)
            .map {AppAction.setFetchResult(pets: $0)}
            .catch{failure -> AnyPublisher<AppAction, Never> in
                .just( AppAction.setFailure(failure))
            }.eraseToAnyPublisher()
    case let .fetchFavourite(page):
        //TODO: Consider creating case specific reducers to reduce the complexity of Switch statement
        return environment.service
            .fetchFavourites(page: page)
            .map {AppAction.setFetchFavouriteResult(pets: $0)}
            .catch{failure -> AnyPublisher<AppAction, Never> in
                .just( AppAction.setFailure(failure))
            }.eraseToAnyPublisher()
    case let .updatePet(pet, image, favourite):
        //TODO: Consider creating case specific reducers to reduce the complexity of Switch statement
        return environment.service
            .setPet(pet, image: image, favourite: favourite)
            .replaceError(with: pet)
            .map { AppAction.setUpdatedPet(pet: $0)}
            .eraseToAnyPublisher()
    }

    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppState, AppAction, PetEnvironment>
