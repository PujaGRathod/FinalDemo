
//
//  StructChat.swift
//  WakeUppApp
//
//  Created by Admin on 20/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructChat
{
    var kid: String
    var kcreateddate: String
    var kdevicetype: String
    var kchatmessage: String
    var kreceiverid: String
    var ksenderid: String
    var ksendername: String
    var kisdeleted:String
    var kisread:String
    var kmessagetype:String
    var kmediaurl:String
    var kchatid:String
    var kuserprofile :String
    var kuseronline:String
    var kuserlastlogin:String
    var kusername:String
    var kuserid:String
    var kunreadcount:String //FOR FRIENDS TABLE IN CORE DB
    var kmuted_by_me:String //FOR FRIENDS TABLE IN CORE DB (me = friend | not the loggedin user)
    var kcountrycode:String
    var kphonenumber:String
    var isstarred:String
    var blocked_contacts:String //FOR FRIENDS TABLE IN CORE DB
    var parentid:String
    var ishidden:String //FOR CHATLISTVC HIDDEN CHATS
    var ispinned:String //FOR CHATLISTVC PINNED CHATS
    var bio:String //PV
    var mediasize:String
    var receivetime:String
    var readtime:String
    
    //-->
    var about_privacy:String
    var photo_privacy:String
    var read_receipts_privacy:String
    var status_privacy:String
    var lastseen_privacy:String
    
    init(dictionary: [String: Any]) {
        self.kid            = "\(dictionary["id"] ?? "")"
        self.kcreateddate   = "\(dictionary["createddate"] ?? "")"
        self.kdevicetype    = "\(dictionary["platform"] ?? "")"
        self.kchatmessage   = "\(dictionary["textmessage"] ?? "")"
        self.kreceiverid    = "\(dictionary["receiverid"] ?? "")"
        self.ksenderid      = "\(dictionary["senderid"] ?? "")"
        self.ksendername    = "\(dictionary["sendername"] ?? "")"
        self.kisdeleted     = "\(dictionary["isdeleted"] ?? "")"
        self.kisread        = "\(dictionary["isread"] ?? "")"
        self.kmediaurl      = "\(dictionary["mediaurl"] ?? "")"
        self.kmessagetype   = "\(dictionary["messagetype"] ?? "")"
        self.kchatid        = "\(dictionary["chatid"] ?? "")"
        self.kuserprofile   = "\(dictionary["image"] ?? "")"
        self.kuseronline    = "\(dictionary["is_online"] ?? "")"
        self.kuserlastlogin = "\(dictionary["last_login"] ?? "")"
        self.kusername      = "\(dictionary["username"] ?? "")"
        self.kuserid        = "\(dictionary["user_id"] ?? "")"
        self.kunreadcount   = "0"
        self.kmuted_by_me   = "\(dictionary["muted_by_me"] ?? "")"
        self.kcountrycode   = "\(dictionary["country_code"] ?? "")"
        self.kphonenumber   = "\(dictionary["phoneno"] ?? "")"
        
        self.isstarred      = "0"
        
        self.blocked_contacts = "\(dictionary["blocked_contacts"] ?? "")"
        self.parentid       = "\(dictionary["parent_id"] ?? "0")"
        
        self.ishidden       = "\(dictionary["ishidden"] ?? "0")"
        self.ispinned       = "\(dictionary["ispinned"] ?? "0")"
        
        self.bio       = "\(dictionary["bio"] ?? "")"
        //-->
        self.about_privacy = "\(dictionary["about_privacy"] ?? "")"
        self.photo_privacy = "\(dictionary["photo_privacy"] ?? "")"
        self.read_receipts_privacy = "\(dictionary["read_receipts_privacy"] ?? "")"
        self.status_privacy = "\(dictionary["status_privacy"] ?? "")"
        self.lastseen_privacy = "\(dictionary["lastseen_privacy"] ?? "")"
        
        let sizemb = fileSizeInMB("\(dictionary["mediasize"] ?? "0")")
        self.mediasize       = sizemb
        self.readtime = "\(dictionary["readtime"] ?? "")"
        self.receivetime = "\(dictionary["receivetime"] ?? "")"
        if self.kuserid == ""{
            self.kuserid    = (self.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)) ? self.ksenderid : self.kreceiverid
        }
        
        if self.kmediaurl.count > 0 && self.kmediaurl.hasPrefix("http") == false && self.kmediaurl.hasPrefix("file") == false && self.kmediaurl.hasPrefix("/") == false{
            if self.kmessagetype != "4"{
                self.kmediaurl   = Get_Chat_Attachment_URL + self.kmediaurl
            }
        }
    }
}




