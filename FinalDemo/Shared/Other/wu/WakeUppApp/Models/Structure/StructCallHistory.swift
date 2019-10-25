//
//  StructCallHistory.swift
//  WakeUppApp
//
//  Created by Admin on 13/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructCallHistory {
    
    var image:String
    var name:String
    var status:String
    var date:String
    var is_video_call:String
    var call_from:String
    var call_to:String
    var call_id:String
    var isseen:String
    
    init(dictionary:[String:Any]){
        image = "\(dictionary["image"] ?? "")"
        name = "\(dictionary["name"] ?? "")"
        status = "\(dictionary["status"] ?? "")"
        date = "\(dictionary["date"] ?? "")"
        is_video_call = "\(dictionary["is_video_call"] ?? "")"
        call_from = "\(dictionary["call_from"] ?? "")"
        call_to = "\(dictionary["call_to"] ?? "")"
        call_id = "\(dictionary["call_id"] ?? "")"
        isseen = "\(dictionary["isseen"] ?? "")"
    }
}

