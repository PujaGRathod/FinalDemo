//
//  StructGroup.swift
//  WakeUppApp
//
//  Created by Admin on 24/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructGroupChat{
    
    var id:String
    var groupid:String
    var senderid:String
    var sendername:String
    var receiverid:String
    var textmessage:String
    var isread:String
    var platform:String
    var isdeleted:String
    var createddate:String
    var messagetype:String
    var mediaurl:String
    var isstarred:String
    var parent_id:String
    var countrycode:String
    var phonenumber:String
    var mediasize:String
    
    init(dictionary:[String:Any]){
        id          = "\(dictionary["id"] ?? "")"
        groupid     = "\(dictionary["groupid"] ?? "")"
        senderid    = "\(dictionary["senderid"] ?? "")"
        sendername  = "\(dictionary["sendername"] ?? "")"
        receiverid  = "\(dictionary["receiverid"] ?? "")"
        textmessage = "\(dictionary["textmessage"] ?? "")"
        isread      = "\(dictionary["isread"] ?? "")"
        platform    = "\(dictionary["platform"] ?? "")"
        isdeleted   = "\(dictionary["isdeleted"] ?? "")"
        createddate = "\(dictionary["createddate"] ?? "")"
        messagetype = "\(dictionary["messagetype"] ?? "")"
        mediaurl    = "\(dictionary["mediaurl"] ?? "")"
        isstarred   = "\(dictionary["isstarred"] ?? "0")"
        parent_id   = "\(dictionary["parent_id"] ?? "0")"
        
        //countrycode = "\(dictionary["countrycode"] ?? "")"
        //phonenumber = "\(dictionary["phonenumber"] ?? "")"
        countrycode = "\(dictionary["country_code"] ?? "")"
        phonenumber = "\(dictionary["phoneno"] ?? "")"
        
        let sizemb = fileSizeInMB("\(dictionary["mediasize"] ?? "0")")
        self.mediasize = sizemb
        
        if mediaurl.count > 0 && mediaurl.hasPrefix("http") == false && self.mediaurl.hasPrefix("file") == false && self.mediaurl.hasPrefix("/") == false{
            if self.messagetype != "4"{
                mediaurl = Get_Chat_Attachment_URL + mediaurl
            }
        }
        
    }
}

