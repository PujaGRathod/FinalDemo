//
//  RMFollowers.swift
//  remone
//
//  Created by Inheritx on 24/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit





class RMFollowers: NSObject{
    let user: RMUser
    let id: String
    
    init(user: RMUser, id: String) {
        self.user = user
        self.id = id
    }
    
    func getRawData() -> [String: Any] {
        var rawData: [String: Any] = [:]
        rawData["id"] = self.id
        return rawData
    }
    
}
