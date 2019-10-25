//
//  StructBroadcastList.swift
//  WakeUppApp
//
//  Created by Admin on 28/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructBroadcastList{
    
    var broadcastListID:String
    var lastMediaURL: String
    var lastMessage: String
    var lastMessageDate: String
    var lastMessageId: String
    var lastMessageType: String
    var members:String
    var memberNames:String
    var memberPhotos:String
    var name:String
    var ispinned:String
    
    init(dictionary:[String:Any]) {
        broadcastListID = "\(dictionary["broadcastListID"] ?? "")"
        lastMediaURL = "\(dictionary["mediaurl"] ?? "")"
        lastMessage = "\(dictionary["textmessage"] ?? "")"
        lastMessageDate = "\(dictionary["createddate"] ?? "")"
        lastMessageId = "\(dictionary["id"] ?? "")"
        lastMessageType = "\(dictionary["messagetype"] ?? "")"
        members = "\(dictionary["members"] ?? "")"
        memberNames = "\(dictionary["memberNames"] ?? "")"
        memberPhotos = "\(dictionary["memberPhotos"] ?? "")"
        name = "\(dictionary["name"] ?? "")"
        ispinned = "\(dictionary["ispinned"] ?? "0")"
        
        if lastMessageDate.count == 0{
            let date = NSDate()
            let strDate = DateFormater.getStringFromDate(givenDate: date)
            lastMessageDate = strDate
        }
    }
    
}
