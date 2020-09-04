//
//  PetApiMock.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

/// Pet API Mock
struct PetApiMock: PetRepository {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        let pets = ["https://dog1.jpg", "https://dog2.jpg", "https://dog3.jpg"].map{Pet.init($0)}
        return .future(pets)
    }
    
    func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure> {
        if let path = Bundle.main.path(forResource: "dog1", ofType: "jpg") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return .future(data)
            }
        }
        return .fail(.invalidRequest)
    }
    
    func fetchFavourites(page: Int) -> AnyPublisher<[Pet], PetFailure> {
        let pets = ["https://dog1.jpg", "https://dog2.jpg", "https://dog3.jpg"].map{Pet.init($0)}
        return .future(pets)
    }

    func petImage() -> Image {
        if let path = Bundle.main.path(forResource: "dog1", ofType: "jpg") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return Image(uiImage: UIImage(data: data)!)
            }
        }
        return Image(systemName: "hourglass")
    }
}
