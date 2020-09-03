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

/// Pet API
public struct PetApi: PetApiProtocol {
    public let sessionConfiguration: URLSessionConfiguration
    private let host: String = "https://shibe.online/api/shibes"
    public init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
    }
    
    /// Fetches Pets information
    /// - Parameter request: Request details for fetching pets
    /// - Returns: Pets details publisher
    public func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        guard let urlQuery = request.urlQueryString(),
              let url = URL(string: host + "?" + urlQuery) else {
            return .fail(.invalidRequest)
        }
        
        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: url)
        let publisher = session.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) -> Data in
                guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    throw PetFailure.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? Int(-1) )
                }
                return data
            })
            .mapError{ error -> PetFailure in
                let nsError = error as NSError

                if nsError.code == -1200 {
                    return .sslError
                }
                return .reason(error: error)
        }.eraseToAnyPublisher()
        
        let result: AnyPublisher<[String], PetFailure> = publisher.unwrap(with: JsonWrapper())
            .eraseToAnyPublisher()
        
        let transformed: AnyPublisher<[Pet], PetFailure> = result.flatMap { (urls) ->  AnyPublisher<[Pet], PetFailure> in
            let pets = urls.map{Pet.init($0)}
            return .future(pets)
        }.eraseToAnyPublisher()
        
        return transformed
    }
    
}
