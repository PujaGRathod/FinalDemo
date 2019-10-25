//
//  Utils.swift
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

import Foundation

// Configure remote URL to fetch token from
var videoTokenUrl = URL_VideoCallToken

// Helper to determine if we're running on simulator or device
struct PlatformUtils {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

struct TokenUtils {
    static func fetchToken(forRoomName roomName:String) throws -> String {
        var token: String = "TWILIO_ACCESS_TOKEN"
        let requestURL: URL = URL(string: "\(videoTokenUrl)?identity=\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))&room=\(roomName)")!
        do {
            let data = try Data(contentsOf: requestURL)
            if let tokenReponse = String.init(data: data, encoding: String.Encoding.utf8) {
                token = tokenReponse
            }
        } catch let error as NSError {
            print ("Invalid token url, error = \(error)")
            throw error
        }
        return token
    }
}
