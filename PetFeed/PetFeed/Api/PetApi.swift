//
//  PetApiProtocol.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

public protocol PetApiProtocol {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure>
}

public struct PetApi: PetApiProtocol {
    public let sessionConfiguration: URLSessionConfiguration
    public init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
    }
    public func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        return .fail(.unknownError)
    }
}
