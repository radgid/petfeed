//
//  ErrorViewModifier.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 07/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct ErrorViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .frame(minWidth: 260, idealWidth: 260, maxWidth: .infinity,
                   minHeight: 100, idealHeight: 100, maxHeight: 100, alignment: .leading)
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .background(LinearGradient.init(gradient: .init(colors: [Color(.systemGray),Color(.systemRed).opacity(0.8)]),
                                            startPoint: .top,
                                            endPoint: .bottom))
            .cornerRadius(8)
    }
}
