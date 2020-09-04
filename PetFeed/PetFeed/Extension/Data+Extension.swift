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
    func asImage() -> Image? {
        if let uiImage = UIImage(data: self) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
