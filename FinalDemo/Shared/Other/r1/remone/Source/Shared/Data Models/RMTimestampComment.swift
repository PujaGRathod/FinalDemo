//
//  RMTimestampComment.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class RMTimestampComment: NSObject {
    let id: String
    var userTimeStamp: RMTimestamp?
    let user: RMUser
    let time: Date
    let text: String

    init?(with data: [String: Any]) {
        if let idString = data.stringValue(forkey: "id"),
            let startTime = data["createdAt"] as? Double,
            let userData = data["user"] as? [String: Any],
            let user = RMUser.init(with: userData) {

            self.id = idString
            self.user = user
            if let stamp = data["commenterLatestTimestamp"] as? [String: Any],
                let timStamp = RMTimestamp.init(with: stamp) {
                self.userTimeStamp = timStamp
            }
            self.text = data.stringValue(forkey: "comment") ?? ""
            self.time = Date.init(timeIntervalSince1970: (startTime / 1000))

        } else {
            return nil
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? RMTimestampComment {
            return self.id == rhs.id
        }
        return false
    }
}
