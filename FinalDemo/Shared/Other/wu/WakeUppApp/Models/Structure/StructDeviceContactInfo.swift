//
//  StructDeviceContactInfo.swift
//  WakeUppApp
//
//  Created by C025 on 09/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct StructDeviceContactInfo
{
    var Name: String?
    var CountryCode: String?
    var PhoneNo: String?
    var CountryCode_PhoneNo: String?
    
    init(dictionary: [String: Any]) {
        self.Name = "\(dictionary[""] ?? "")"
        self.CountryCode = "\(dictionary[""] ?? "")"
        self.PhoneNo = "\(dictionary[""] ?? "")"
        self.CountryCode_PhoneNo = "\(dictionary[""] ?? "")"
    }
    
    init(Name:String, CountryCode:String, PhoneNo:String) {
        /*self.Name = Name
        self.CountryCode = CountryCode
        self.PhoneNo = PhoneNo
        self.CountryCode_PhoneNo = "\(CountryCode ?? "")\(PhoneNo)"*/
        
        if Name.count == 0 || Name.uppercased() == "N/A".uppercased() || Name.uppercased() == "null".uppercased() { self.Name = "" }
        else { self.Name = Name }
        
        if PhoneNo.count == 0 || PhoneNo.uppercased() == "N/A".uppercased() || PhoneNo.uppercased() == "null".uppercased() { self.PhoneNo = "" }
        else { self.PhoneNo = PhoneNo }
        
        if CountryCode.count == 0 || CountryCode.uppercased() == "N/A".uppercased() || CountryCode.uppercased() == "null".uppercased() || CountryCode.uppercased() == "(null)".uppercased() {
            self.CountryCode = "" }
        else { self.CountryCode = CountryCode }
  
        self.CountryCode_PhoneNo = "\(self.CountryCode ?? "")\(self.PhoneNo ?? "")" 
    }
}
