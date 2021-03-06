//
//  Publisher+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

typealias PetPublisher = AnyPublisher<Data, PetFailure>
///Default implementation of Data unwrap method for the PetPublisher
extension PetPublisher {
    func unwrap<O: Decodable>(with wrapper: ModelWrapper) -> AnyPublisher<O, PetFailure> {
        return wrapper.unwrap(publisher: self.eraseToAnyPublisher())
    }
}

/// Helper methods to wrap  Combine Async methods 
extension Publisher {

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty()
            .eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Never> {
        return Just(output)
            .eraseToAnyPublisher()
    }

    static func future(_ output: Output, failure: Failure? = nil) -> AnyPublisher<Output, Failure> {
        return Future<Output, Failure>.init { promise in
            return promise(.success(output))
        }.eraseToAnyPublisher()
    }

    static func fail<O>(_ error: Failure) -> AnyPublisher<O, Failure> {
        return Fail(outputType: O.self, failure: error).eraseToAnyPublisher()
    }

}
