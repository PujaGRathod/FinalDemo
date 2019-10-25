//
//  NSErrorExtension.swift
//  remone
//
//  Created by Arjav Lad on 21/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation

extension NSError {
    class func error(with message: String) -> NSError {
        let error = NSError.init(domain: "Local", code: 0, userInfo: [NSLocalizedDescriptionKey : message])
        return error
    }
}
