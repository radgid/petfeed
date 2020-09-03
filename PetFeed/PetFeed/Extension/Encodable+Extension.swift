//
//  Encodable+Extension.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
extension Encodable {
    func urlParams() -> [String]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let dict = try? (JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]) else { return nil }
        let urlQueryParamsString: [String]?  = dict.compactMap { (key, value) in
            if let valueArr = value as? [String] {
                let values = "[" + valueArr.map {"\"" + $0 + "\""}.joined(separator: ",") + "]"
                return "\(key)=\(values)"
            } else if let valueArr = value as? [Int] {
                let values = "[" + valueArr.map {String($0)}.joined(separator: ",") + "]"
                return "\(key)=\(values)"
            } else {
                if let val = value as? String, val.count > 0 {
                    return "\(key)=\(value)"
                } else if let val = value as? Bool {
                    return "\(key)=\(val == true ? "true" : "false")"
                } else {
                    return "\(key)=\(value)"
                }
            }
        }
        return urlQueryParamsString
    }

    func urlQueryString() -> String? {
        guard let urlParams = urlParams() else {
            return nil
        }
        let urlQueryParamsString = urlParams.joined(separator: "&")
        return urlQueryParamsString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }
}
