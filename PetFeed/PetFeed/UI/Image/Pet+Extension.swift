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
    func image(from cache: ImageCache) -> Image {
        if let url = URL(string: url) {
            if let image = cache[url] {
                return Image(uiImage: image)
            }
        }
        return Image(systemName: "hourglass")
    }
}
