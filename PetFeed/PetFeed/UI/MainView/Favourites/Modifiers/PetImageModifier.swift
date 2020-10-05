//
//  PetImageModifier.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

struct PetImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(height: 180)
            .padding()
    }
}
