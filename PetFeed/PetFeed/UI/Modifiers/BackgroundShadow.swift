//
//  BackgroundShadow.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 07/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

struct BackgroundShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.white.opacity(0.9), radius: 10, x: -10, y: -10)
            .shadow(color: Color.gray.opacity(0.5), radius: 14, x: 14, y: 14)
    }
}
