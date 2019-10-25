//
//  User.swift
//  FinalDemo
//
//  Created by POOJA on 25/10/19.
//  Copyright © 2019 POOJA. All rights reserved.
//

import UIKit

struct UserModel{
    
    var userId:String
    var userName:String
    
    init(dictionary:[String:Any]) {
        userId          = "\(dictionary["userId"] ?? "")"
        userName     = "\(dictionary["userName"] ?? "")"        
    }
}
