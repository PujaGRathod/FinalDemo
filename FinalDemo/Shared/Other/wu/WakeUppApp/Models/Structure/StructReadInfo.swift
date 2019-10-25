//
//  StructReadInfo.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 25/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
struct StructReadInfo{
    
    var groupchatid: String
    var receivetime: String
    var readtime: String
    var userid: String
    var username:String
    var image:String
    var countrycode:String
    var phoneno:String
    
    init(dictionary: [String: Any])
    {
        self.groupchatid =  "\(dictionary["groupchatid"] ?? "")"
        self.receivetime = "\(dictionary["receivetime"] ?? "")"
        //self.receivetime = DateFormater.generateDateWithFormat2FromGivenDatestring(strDate: "\(dictionary["receivetime"] ?? "")");
        let strimg =  dictionary["image"] as? String ?? "".lowercased()
        let url = "\(Get_Profile_Pic_URL)/\(strimg)"
        self.image =  url
        self.readtime = "\(dictionary["readtime"] ?? "")"
        //self.readtime  =  DateFormater.generateDateWithFormat2FromGivenDatestring(strDate: "\(dictionary["readtime"] ?? "")");
        self.userid  =   "\(dictionary["userid"] ?? "")"
        self.username  =   "\(dictionary["full_name"] ?? "")"
        
        self.receivetime = self.receivetime.replacingOccurrences(of: "T", with: " ")
        self.receivetime = self.receivetime.components(separatedBy: ".").first!
        //self.receivetime = DateFormater.generateDateWithFormat2FromGivenDatestring(strDate: self.receivetime)
        
        self.receivetime = timeAgoSinceStrDate(strDate: self.receivetime, numericDates: true)
        
        
        if readtime == "0000-00-00 00:00:00"{
            readtime = "-"
        }else{
            self.readtime = self.readtime.replacingOccurrences(of: "T", with: " ")
            self.readtime = self.readtime.components(separatedBy: ".").first!
            //self.readtime = DateFormater.generateDateWithFormat2FromGivenDatestring(strDate: self.readtime)
            self.readtime = timeAgoSinceStrDate(strDate: self.readtime, numericDates: true)
        }
        
        self.countrycode = "\(dictionary["country_code"] ?? "")"
        self.phoneno = "\(dictionary["phoneno"] ?? "")"
    }
}
