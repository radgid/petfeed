//
//  Pet+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

extension Pet {
    func uiImage(from cache: ImageCache) -> UIImage? {
        if let url = URL(string: url) {
            return cache[url]
        }
        return nil
    }
    
    func image(from cache: ImageCache) -> Image {
        if let image = uiImage(from: cache) {
            return Image(uiImage: image)
        }
        return Image(systemName: "hourglass")
    }
}
