//
//  Data+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension Data {
    /// Converts data into Image - data read from file system or received from web
    /// - Returns: Image if Data is valid UIImage data
    func asImage() -> Image? {
        if let uiImage = UIImage(data: self) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
