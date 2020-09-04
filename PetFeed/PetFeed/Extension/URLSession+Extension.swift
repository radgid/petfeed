//
//  URLSession+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine

extension URLSession {
    
    func petPublisher(for request: URLRequest) -> PetPublisher {
        self.dataTaskPublisher(for: request)
            .tryMap({ (data: Data, response: URLResponse) -> Data in
                guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                    throw PetFailure.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? Int(-1) )
                }
                return data
            })
            .mapError { error -> PetFailure in
                let nsError = error as NSError

                if nsError.code == -1200 {
                    return .sslError
                }
                return .reason(error: error)
        }.eraseToAnyPublisher()
    }
}
