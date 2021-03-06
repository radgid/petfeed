//
//  ModelWrapper.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

/// Support for unwrapping the Data into the Decodable structure
protocol ModelWrapper {
    init()
    func unwrap<V: Decodable>(publisher: PetPublisher) -> AnyPublisher<V, PetFailure>
}

/// Implementation of Json data unwrapping into Decodable structure
struct JsonWrapper: ModelWrapper {

    init() {}
    func unwrap<V: Decodable>(publisher: PetPublisher) -> AnyPublisher<V, PetFailure> {
        return publisher
            .decode(type: V.self, decoder: JSONDecoder())
            .mapError {error -> PetFailure in

                _ = publisher.sink(receiveCompletion: {_ in}, receiveValue: { data in
                    let errString = "Unwrap error:\ntype: " +
                        String(describing: V.self) +
                        "\ndetail: " + String(describing: error) +
                        "\npayload: " + (String(data: data, encoding: .utf8) ?? "")
                    Log.data().error(message: errString)
                })

                if let fail = error as? PetFailure {
                    return fail
                }
                return .unwrapingError(error: error)
            }.eraseToAnyPublisher()
    }
}
