//
//  Store.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

///Reducer to determine the changes to the appState 
typealias Reducer<State, Action, PetEnvironment> =
(inout State, Action, PetEnvironment) -> AnyPublisher<Action, Never>?

/// Store to keep the single source of truth "State" and an environment which will be responsible for any data manipulation work
final class Store<State, Action, PetEnvironment>: ObservableObject {
    @Published private(set) var state: State

    public let environment: PetEnvironment
    private let reducer: Reducer<State, Action, PetEnvironment>
    private var cancellables: Set<AnyCancellable> = []

    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, PetEnvironment>,
        environment: PetEnvironment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    public func send(_ action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
}
