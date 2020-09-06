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

/// Pet API Mock - used in Unit Tests as well as SwiftUi Previews
struct PetApiMock: PetRepository {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        let pets = ["https://dog1.jpg", "https://dog2.jpg", "https://dog3.jpg"].map {Pet.init($0, isFavourite: false)}
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

    func fetchFavourites(page: Int) -> AnyPublisher<[DisplayablePet], PetFailure> {
        let pets = ["https://dog1.jpg", "https://dog2.jpg", "https://dog3.jpg"].map {DisplayablePet.init(id: $0, image: petImage())}
        return .future(pets)
    }

    func petImageData() -> Data? {
        if let path = Bundle.main.path(forResource: "dog1", ofType: "jpg") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return data
            }
        }
        return UIImage(systemName: "hourglass")?.jpegData(compressionQuality: 1.0)
    }

    func petImage() -> Image {
        if let path = Bundle.main.path(forResource: "dog1", ofType: "jpg") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return data.asImage()!
            }
        }
        return Image(systemName: "hourglass")
    }

    func setPet(_ pet: Pet,
                image: Data? = nil,
                favourite: Bool) -> AnyPublisher<Pet, PetFailure> {
        return .fail(.invalidRequest)
    }
}
