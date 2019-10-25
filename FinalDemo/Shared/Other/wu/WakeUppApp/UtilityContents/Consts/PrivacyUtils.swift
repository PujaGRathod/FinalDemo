//
//  PrivacyUtils.swift
//  WakeUppApp
//
//  Created by Admin on 13/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum enumPrivacyOption : String {
    case enumPrivacyOption_Nobody = "Nobody" // 0
    case enumPrivacyOption_Mycontact = "My Contacts" // 1
    case enumPrivacyOption_Everyone = "Everyone" // 2
    
    //NOTE : Write Comment value send in API - 62 (update_user_settings) in "value" parameter
    // If set "lastseen_privacy" to everyone to send this type (lastseen_privacy) value in API Request.
    // "request": { "value": "1", "action":"lastseen_privacy" }
}

enum enumPrivacyStatus : String {
    case enumPrivacyStatus_Nobody = "0"
    case enumPrivacyStatus_Mycontact = "1"
    case enumPrivacyStatus_Everyone = "2"
    
    //NOTE : Write Comment value send in API - 62 (update_user_settings) in "value" parameter
    // If set "lastseen_privacy" to everyone to send this type (lastseen_privacy) value in API Request.
    // "request": { "value": "1", "action":"lastseen_privacy" }
}

//MARK: Profile Photo
func Privacy_ProfilePhoto_Show(userID : String) -> Bool {
    if (userID.count != 0) {
        let getUserInfo = CoreDBManager.sharedDatabase.getFriendById(userID: userID)
        return Privacy_ProfilePhoto_Show(statusFlag: getUserInfo?.photo_privacy ?? "1")
    }
    return false
}

func Privacy_ProfilePhoto_Show(statusFlag : String) -> Bool {
    if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Nobody.rawValue.uppercased()) {
        return false
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Mycontact.rawValue.uppercased()) {
        return true
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Everyone.rawValue.uppercased()) {
        return true
    }
    //return false
    return true
}

//MARK: Last Seen
func Privacy_LastSeen_Show(userID : String) -> Bool {
    if (userID.count != 0) {
        let getUserInfo = CoreDBManager.sharedDatabase.getFriendById(userID: userID)
        return Privacy_ProfilePhoto_Show(statusFlag: getUserInfo?.lastseen_privacy ?? "1")
    }
    return false
}
func Privacy_LastSeen_Show(statusFlag : String) -> Bool {
    if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Nobody.rawValue.uppercased()) {
        return false
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Mycontact.rawValue.uppercased()) {
        return true
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Everyone.rawValue.uppercased()) {
        return true
    }
    return false
}
//MARK: About
func About_LastSeen_Show(userID : String) -> Bool {
    if (userID.count != 0) {
        let getUserInfo = CoreDBManager.sharedDatabase.getFriendById(userID: userID)
        return Privacy_ProfilePhoto_Show(statusFlag: getUserInfo?.about_privacy ?? "1")
    }
    return false
}

func About_LastSeen_Show(statusFlag : String) -> Bool {
    if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Nobody.rawValue.uppercased()) {
        return false
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Mycontact.rawValue.uppercased()) {
        return true
    }
    else if (statusFlag.uppercased() == enumPrivacyStatus.enumPrivacyStatus_Everyone.rawValue.uppercased()) {
        return true
    }
    return false
}
