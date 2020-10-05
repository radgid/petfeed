//
//  PetApiProtocol.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

/// Data Repository interfaces
protocol NetworkPetRepository {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure>
    func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure>
}

/// Pet API
struct NetworkPetApi: NetworkPetRepository {
    
    private let sessionConfiguration: URLSessionConfiguration
    private let host: String = "https://shibe.online/api/"
    private let localRepository: LocalPetRepository
    
    init(sessionConfiguration: URLSessionConfiguration = .default,
         localRepository: LocalPetRepository) {
        self.sessionConfiguration = sessionConfiguration
        self.localRepository = localRepository
    }
    
    /// Fetches Pets information
    /// - Parameter request: Request details for fetching pets
    /// - Returns: Pets details publisher
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        guard let url = URL(string: host + request.api() + "?" + "count=\(request.count)") else {
                return .fail(.invalidRequest)
        }

        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: url)
        let publisher = session.petPublisher(for: urlRequest)
        let favouriteIds = localRepository.fetchFavouritesIds()
        //Unwrap Array of Strings from the Json
        let result: AnyPublisher<[String], PetFailure> = publisher.unwrap(with: JsonWrapper())
            .eraseToAnyPublisher()

        //Transform Array of string into Pet structures
        let transformed: AnyPublisher<[Pet], PetFailure> =
            result.flatMap { (urls) ->  AnyPublisher<[Pet], PetFailure> in
                let pets = urls.map {Pet.init($0, isFavourite: favouriteIds.contains($0))}
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
