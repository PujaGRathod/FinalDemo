//
//  VoiceCallUtils.swift
//  WakeUppApp
//
//  Created by Admin on 09/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

public let baseURLString = URL_VoiceCallToken

public let twimlParamTo = "To"
public let twimlParamFrom = "Clientname"

var outgoingName:String?
var deviceTokenString:String?

var identity : String{
    let strIdentity = "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))__\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))__\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))"
    
    return strIdentity.replacingOccurrences(of: " ", with: "")
    /*let strIdentity = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
    return strIdentity*/
}

func fetchAccessToken() -> String? {
    let endpointWithIdentity = String(format: "%@?identity=%@", baseURLString, identity)
    
    let escapedString = endpointWithIdentity.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

    guard let accessTokenURL = URL(string: escapedString) else {
        return nil
    }
    return try? String.init(contentsOf: accessTokenURL, encoding: .utf8)
}
