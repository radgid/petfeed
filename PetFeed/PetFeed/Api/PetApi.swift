//
//  PetApiProtocol.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

protocol PetRepository {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure>
    func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure>
}

/// Pet API
struct PetApi: PetRepository {

    private let sessionConfiguration: URLSessionConfiguration
    private let host: String = "https://shibe.online/api/shibes"
    init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
    }

    /// Fetches Pets information
    /// - Parameter request: Request details for fetching pets
    /// - Returns: Pets details publisher
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        guard let urlQuery = request.urlQueryString(),
              let url = URL(string: host + "?" + urlQuery) else {
            return .fail(.invalidRequest)
        }

        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: url)
        let publisher = session.petPublisher(for: urlRequest)

        //Unwrap Array of Strings from the Json
        let result: AnyPublisher<[String], PetFailure> = publisher.unwrap(with: JsonWrapper())
            .eraseToAnyPublisher()

        //Transform Array of string into Pet structures
        let transformed: AnyPublisher<[Pet], PetFailure> = result.flatMap { (urls) ->  AnyPublisher<[Pet], PetFailure> in
            let pets = urls.map {Pet.init($0)}
            return .future(pets)
        }.eraseToAnyPublisher()

        return transformed
    }
    
    /// Download image from URL
    /// - Parameter imageUrl: URL of the Image
    /// - Returns: Image Data Publisher
    public func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure> {
        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: imageUrl)
        let publisher = session.petPublisher(for: urlRequest)

        return publisher
    }
}
