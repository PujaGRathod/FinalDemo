//
//  StructReadInfo_PersonalChat.swift
//  WakeUppApp
//
//  Created by Admin on 18/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
struct StructReadInfo_PersonalChat {
    
    var id: String
    var isread: String
    var readtime: String
    var receiverid: String
    var receivetime: String
    var senderid:String
    
    init(dictionary: [String: Any]) {
        self.id =  "\(dictionary["id"] ?? "")"
        self.isread = "\(dictionary["isread"] ?? "")"
        self.receiverid = "\(dictionary["receiverid"] ?? "")"
        self.senderid = "\(dictionary["senderid"] ?? "")"
        self.readtime = "\(dictionary["readtime"] ?? "")"
        self.receivetime = "\(dictionary["receivetime"] ?? "")"
        
        //readtime
        if readtime == "0000-00-00 00:00:00" { readtime = "-" }
        else {
            self.readtime = self.readtime.replacingOccurrences(of: "T", with: " ")
            self.readtime = self.readtime.components(separatedBy: ".").first!
            self.readtime = timeAgoSinceStrDate(strDate: self.readtime, numericDates: true)
        }
        
        //receivetime
        if receivetime == "0000-00-00 00:00:00" { receivetime = "-" }
        else {
            self.receivetime = self.receivetime.components(separatedBy: ".").first!
            self.receivetime = self.receivetime.components(separatedBy: ".").first!
            self.receivetime = timeAgoSinceStrDate(strDate: self.receivetime, numericDates: true)
        }
    }
}
