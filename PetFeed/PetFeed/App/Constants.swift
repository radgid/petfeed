//
//  Constants.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import CoreGraphics

/// Constants used throughout the App
struct Constants {
    static let pageSize = 50
    //TODO: Paging to be considered - at the moment the Mock Pet server does not preserve any kind of sort so paging makes only sence
    // in terms of loading batches of data as oposed to sorted data
    static let pullToRefreshOffset = CGFloat(120.0)
}
