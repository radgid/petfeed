//
//  Notification+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 08/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didDismissPetDetail = Notification.Name("didDismissPetDetail")
}

extension Notification {
    static func send(name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
