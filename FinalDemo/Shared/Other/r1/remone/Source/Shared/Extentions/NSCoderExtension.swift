
//
//  NSCoderExtension.swift
//  remone
//
//  Created by Arjav Lad on 25/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation

extension NSCoder {
    func getStringValue(for key: String) -> String? {
        if let value = self.decodeObject(forKey: key) {
            return "\(value)"
        } else {
            return nil
        }
    }
}
