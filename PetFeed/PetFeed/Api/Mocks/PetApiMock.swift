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

extension UIImage {

    func tint(_ color: UIColor) -> UIImage {
        let maskImage = cgImage
        let bounds = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.clip(to: bounds, mask: maskImage!)
            color.setFill()
            cgContext.fill(bounds)
        }
    }
    
    public func rotate(angle:CGFloat)->UIImage
     {
         let radians = CGFloat(angle * .pi) / 180.0 as CGFloat
         
         var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
         
         newSize.width = floor(newSize.width)
         newSize.height = floor(newSize.height)
         let renderer = UIGraphicsImageRenderer(size:self.size)
         
         let image = renderer.image
         { rendederContext in
             
             let context = rendederContext.cgContext
             //rotate from center
             context.translateBy(x: newSize.width/2, y: newSize.height/2)
             context.rotate(by: radians)
             draw(in:  CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: size))
         }
         
         return image
     }

}

/// Pet API Mock - used in Unit Tests as well as SwiftUi Previews
struct PetApiMock: LocalPetRepository, NetworkPetRepository {
    var cache = TemporaryImageCache()
    
    init() {
        if let image = petUIImage(),
            let url1 = URL(string:"https://dog1.jpg"),
            let url2 = URL(string:"https://dog2.jpg"),
            let url3 = URL(string:"https://dog3.jpg"){
            cache[url1] = image
            cache[url2] = image.tint(.blue).rotate(angle: 180)
            cache[url3] = image.tint(.green).rotate(angle: 180)
        }
    }
    
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

    func selectPet(_ pet: Pet) -> AnyPublisher<Pet, PetFailure> {
        .future(pet)
    }
    
    func petUIImage() -> UIImage? {
        if let path = Bundle.main.path(forResource: "dog1", ofType: "jpg") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return UIImage(data: data)
            }
        }
        return UIImage(systemName: "hourglass")
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
        return .future(pet)
    }
    
    func fetchFavouritesIds() -> [String] {
        return ["dog1.jpg"]
    }
}
