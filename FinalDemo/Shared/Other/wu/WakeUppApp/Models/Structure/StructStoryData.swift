//
//  StructStoryData.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 18/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

struct StructStoryData
{
    var kstoryid : String
    var kstorytype : String
    var kstoryurl : String
    var kstoryduration : String
    var kstorydate:String
    var kuid: String
    var kuprofile: String
    var kuname:String
    var kisviewed:String
    var kviewerid:String
    var kviewerarr:[StructStoryData]
    var kstoryownername:String
    var kstoryownerprofile:String
    var kviewtime:String
    var ktotalviewer:String
    init(dictionary: [String: Any])
    {
        let strimg =  dictionary["image"] as? String ?? "".lowercased()
        self.kstoryid =  "\(dictionary["status_id"] ?? "")"
        self.kstorytype =  strimg.contains("jpg") || strimg.contains("png") ?  "1" : "0"
        let url = "\(Get_Status_URL)/\(strimg)"
        self.kstoryurl =  url
        self.kstoryduration  =  dictionary["storyduration"] as? String ?? "5"
        self.kstorydate  =  dictionary["creation_datetime"] as? String ?? ""
        self.kuid  = "\(dictionary["storyownerid"] ?? "")"
        let url2 = "\(Get_Profile_Pic_URL)\(dictionary["userprofile"] as? String ?? "".lowercased())"
        self.kuprofile  =  url2
        self.kuname  =  dictionary["username"] as? String ?? ""
        self.kisviewed  =  dictionary["isviewed "] as? String ?? ""
        self.kviewerid  =  "\(dictionary["viewer_id"] ?? "")"
        self.kstoryownername  =  "\(dictionary["username"] ?? "")"
        self.kstoryownerprofile  =  "\(dictionary["userprofile"] ?? "")"
         self.kviewtime  =  "\(dictionary["creation_datetime"] ?? "")"
        self.kviewerarr  =  dictionary["viewer_array "] as? [StructStoryData] ?? []
       self.ktotalviewer = "0"
    }
    public var dictionaryRepresentation: [String: Any]
    {
        return ["status_id":kstoryid,"storytype" : kstorytype,"image" : kstoryurl,"storyduration":kstoryduration,"creation_datetime":kstorydate,"storyownerid":kuid,"userprofile":kuprofile,"username":kuname,"isviewed":kisviewed,"viewer_id":kviewerid,"viewer_array":kviewerarr,"storyownerprofile":kstoryownerprofile,"storyownername":kstoryownername,"viewtime":kviewtime]
    }
}
struct StructStory
{
    var krecentstoryurl: String
    var kstoryarr:[StructStoryData]
    var kuid: String
    var kuprofile: String
    var kuname:String
    var krecentstorydate:String
    var kisviewed:String
    init(dictionary: [String: Any])
    {
        self.krecentstoryurl =  dictionary["storyurl"] as? String ?? ""
        self.kuid  =  "\(dictionary["storyownerid"] ?? "")"
        //let url2 = "\(Get_Profile_Pic_URL)\(dictionary["userprofile"] as? String ?? "".lowercased())"
        self.kuprofile  =  "\(dictionary["userprofile"] as? String ?? "".lowercased())"//url2
        self.kuname  =  dictionary["username"] as? String ?? ""
        self.kstoryarr  =  dictionary["story"] as? [StructStoryData] ?? []
        self.krecentstorydate  =  dictionary["recentstorydate"] as? String ?? ""
        self.kisviewed  =  dictionary["isviewed"] as? String ?? ""
    }
    public var dictionaryRepresentation: [String: Any]
    {
        return ["storyownerid":kuid,"storyurl":krecentstoryurl,"userprofile":kuprofile,"username":kuname,"recentstorydate":
            krecentstorydate  ,"story":kstoryarr,"isviewed":kisviewed]
    }
}

struct StructViewers
{
    var ksid: String
    var kvdate: String
    var kvid: String
    var kvname:String
    var kvpofile:String
    init(dictionary: [String: Any])
    {
        self.ksid =  "\(dictionary["status_id"] ?? "")"
        self.kvdate  =  "\(dictionary["view_date"] ?? "")"
        //let url2 = "\(Get_Profile_Pic_URL)\(dictionary["viewer_pic"] as? String ?? "".lowercased())"
        self.kvpofile  =  "\(dictionary["viewer_pic"] as? String ?? "".lowercased())"//url2
        self.kvname  =  "\(dictionary["viewer_name"] ?? "")"
        self.kvid  =  "\(dictionary["viewer_id"] ?? "")"
    }
    public var dictionaryRepresentation: [String: Any]
    {
        return ["status_id":ksid,"view_date":kvdate,"viewer_pic":kvpofile,"viewer_name":kvname,"viewer_id":
            kvid]
    }
}
