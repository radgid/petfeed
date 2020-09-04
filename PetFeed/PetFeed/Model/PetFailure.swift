//
//  PetFailure.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
public enum PetFailure: Error {
    case reason(error: Error)
    case unknownError
    case invalidRequest
    case serverError(statusCode: Int, reason: String? = nil)
    case sslError
    case unwrapingError(error: Error)
    case databaseError(error: Error)
}
