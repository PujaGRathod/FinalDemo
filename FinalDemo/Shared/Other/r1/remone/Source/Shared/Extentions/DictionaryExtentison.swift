
//
//  DictionaryExtentison.swift
//  remone
//
//  Created by Arjav Lad on 24/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary where Key == String, Value == Any {
    func stringValue(forkey: String) -> String? {
        if let data = self[forkey] {
            if let data = data as? String  {
                return data
            } else if let _ = data as? [String: Any] {
                return nil
            } else if let _ = data as? [Any] {
                return nil
            } else {
                return "\(data)"
            }
        } else {
            return nil
        }
    }

    func intValue(forkey: String) -> Int? {
        if let data = self[forkey] as? Int  {
            return data
        } else {
            return nil
        }
    }
}
