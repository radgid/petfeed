//
//  PetRequest.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

public struct PetRequest: Encodable {
    public let count: Int
    public let urls: Bool?
    public let httpsUrls: Bool?
    public init(count: Int, urls: Bool? = true, httpsUrls: Bool = true) {
        self.count = count
        self.urls = urls
        self.httpsUrls = httpsUrls
    }
}
