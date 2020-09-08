//
//  AsyncImage.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

/// Asynchronous Image loading
 struct AsyncImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    @State private var isSpinning = false
    private let placeholder: Placeholder?

    init(url: URL?, placeholder: Placeholder? = nil,
                cache: ImageCache? = nil,
                service: PetRepository) {
        loader = ImageLoader(url: url, cache: cache, service: service)
        self.placeholder = placeholder
    }

    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }

    var image: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder?
                    .font(.title)
                    .rotationEffect(.degrees(self.isSpinning ? 0 : 360))
                    .animation(Animation.easeInOut(duration:0.5).repeatForever(autoreverses: false))
            }
        }.onAppear {
            self.isSpinning.toggle()
        }
    }
    
    func refreshIfNeeded() {
        if loader.image == nil {
            loader.load()
        }
    }
}
