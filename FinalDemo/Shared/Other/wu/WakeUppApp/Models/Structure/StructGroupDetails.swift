//
//  StructGroupDetails.swift
//  WakeUppApp
//
//  Created by Admin on 24/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructGroupDetails{
    
    var name: String
    var group_id: String
    var icon:String
    var members: String
    var muted_by: String
    var createdby: String
    var admins: String
    var isalladmin: String
    var isdelete: String
    var lastMediaURL: String
    var lastMessageId: String
    var lastMessage: String
    var lastMessageDate: String
    var lastMessageType: String
    var lastMessageSenderId: String
    var lastMessageReceiverIds: String
    var unreadCount: String
    var ishidden: String // FOR CHATLISTVC HIDDEN CHATS
    var ispinned: String //FOR CHATLISTVC PINNED CHATS
    var edit_permission: String
    var msg_permission: String

    init(dictionary:[String:Any]) {
        group_id = "\(dictionary["group_id"] ?? "")"
        name = "\(dictionary["name"] ?? "")"
        icon = "\(dictionary["icon"] ?? "")"
        members = "\(dictionary["members"] ?? "")"
        muted_by = "\(dictionary["muted_by"] ?? "")"
        createdby = "\(dictionary["createdby"] ?? "")"
        admins = "\(dictionary["admins"] ?? "")"
        isalladmin = "\(dictionary["isalladmin"] ?? "")"
        isdelete = "\(dictionary["isdeleted"] ?? "")"
        lastMessageId = "\(dictionary["id"] ?? "")"
        lastMediaURL = "\(dictionary["mediaurl"] ?? "")"
        lastMessage = "\(dictionary["textmessage"] ?? "")"
        lastMessageType = "\(dictionary["messagetype"] ?? "")"
        lastMessageDate = "\(dictionary["createddate"] ?? "")"
        lastMessageSenderId = "\(dictionary["senderid"] ?? "")"
        lastMessageReceiverIds = "\(dictionary["receiverid"] ?? "")"
        
        unreadCount = "0"
        ishidden = "0"
        ispinned = "\(dictionary["ispinned"] ?? "0")"
        
        edit_permission = "\(dictionary["edit_permission"] ?? "0")"
        msg_permission = "\(dictionary["msg_permission"] ?? "0")"
        
        if icon.count > 0 && icon.hasPrefix("http") == false{
            //print("DO NOW")
            icon = Get_Group_Icon_URL + icon
        }
    }
}
