//
//  ImageCache.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI

public protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

/// Image caching
public struct TemporaryImageCache: ImageCache {
    
    private let cache = NSCache<NSURL, UIImage>()

    public subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) :
            cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
