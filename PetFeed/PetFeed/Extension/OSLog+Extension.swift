//
//  OSLog+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import os.log

/// OS Log wrapper to simplify the message logging
enum Log {
    public static var subsystem = Bundle.main.bundleIdentifier!
    case networking(type: OSLog = OSLog(subsystem: subsystem, category: "networking"))
    case data(type: OSLog = OSLog(subsystem: subsystem, category: "data"))
    case user(type: OSLog = OSLog(subsystem: subsystem, category: "user"))

    public func associatedValue() -> OSLog {
        switch self {
        case .networking(let logType):
            return logType
        case .data(let logType):
            return logType
        case .user(let logType):
            return logType
        }
    }

}

extension Log {
    public func info(message: String) {
        os_log("%{public}s", log: self.associatedValue(), type: .info, message)
    }
    public func error(message: String) {
        os_log("%{public}s", log: self.associatedValue(), type: .error, message)
    }
    public func fault(message: String) {
        os_log("%{public}s", log: self.associatedValue(), type: .fault, message)
    }
}
