//
//  Store.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

typealias Reducer<State, Action, PetEnvironment> =
(inout State, Action, PetEnvironment) -> AnyPublisher<Action, Never>?

final class Store<State, Action, PetEnvironment>: ObservableObject {
    @Published private(set) var state: State

    public let environment: PetEnvironment
    private let reducer: Reducer<State, Action, PetEnvironment>
    private var cancellables: Set<AnyCancellable> = []

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, PetEnvironment>,
        environment: PetEnvironment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    func send(_ action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
}

