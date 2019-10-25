//
//  StructBroadcastMessage.swift
//  WakeUppApp
//
//  Created by Admin on 28/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructBroadcastMessage{
    
    var id:String
    var broadcastListID:String
    var senderid:String
    var sendername:String
    var receiverid:String //MEMBERS
    var textmessage:String
    
    var isread:String
    var platform:String
    var isdeleted:String
    var createddate:String
    var messagetype:String
    var mediaurl:String
    var mediasize:String
    
    init(dictionary:[String:Any]){
        id              = "\(dictionary["id"] ?? "")"
        broadcastListID = "\(dictionary["broadcastListID"] ?? "")"
        senderid        = "\(dictionary["senderid"] ?? "")"
        sendername      = "\(dictionary["sendername"] ?? "")"
        receiverid      = "\(dictionary["receiverid"] ?? "")"
        textmessage     = "\(dictionary["textmessage"] ?? "")"
        isread          = "\(dictionary["isread"] ?? "")"
        platform        = "\(dictionary["platform"] ?? "")"
        isdeleted       = "\(dictionary["isdeleted"] ?? "")"
        createddate     = "\(dictionary["createddate"] ?? "")"
        messagetype     = "\(dictionary["messagetype"] ?? "")"
        mediaurl        = "\(dictionary["mediaurl"] ?? "")"
        
        let sizemb = fileSizeInMB("\(dictionary["mediasize"] ?? "0")")
        self.mediasize = sizemb
    }
}

