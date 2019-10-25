//
//  RMTimestamp.swift
//  remone
//
//  Created by Arjav Lad on 27/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

enum TimeStampStatus: String {
    case available = "AVAILABLE"
    case away = "TEMPORARY_WITHDRAW"
    case busy = "BUSY"
    case workFinish = "FINISH"
    
    var text: String {
        switch self {
        case .available:
            return "Can contact".localized
            
        case .away:
            return "Temporarily leaving".localized
            
        case .busy:
            return "Busy".localized
            
        case .workFinish:
            return "".localized
        }
    }

    var displayText: String {
        switch self {
        case .available:
            return "Can contact".localized

        case .away:
            return "Temporarily leaving".localized

        case .busy:
            return "Busy".localized

        case .workFinish:
            return "Work Finish".localized
        }
    }
    
    var miniIcon: UIImage {
        switch self {
        case .available:
            return #imageLiteral(resourceName: "iconAvailable")
            
        case .away:
            return #imageLiteral(resourceName: "iconAway")
            
        case .busy:
            return #imageLiteral(resourceName: "iconDoNotDisturb")
            
        case .workFinish:
            return UIImage()
        }
    }
    
    var color: UIColor {
        switch self {
        case .available:
            return #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)
            
        case .away:
            return #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
            
        case .busy:
            return #colorLiteral(red: 0.7882352941, green: 0.2431372549, blue: 0.2862745098, alpha: 1)
            
        case .workFinish:
            return UIColor.clear
        }
    }

    var sortOrder: Int {
        switch self {
        case .available:
            return 0

        case .busy:
            return 1

        case .away:
            return 2

        case .workFinish:
            return 3
        }
    }


}

class RMTimestamp: NSObject {
    let id: String
    var details: String = ""
    var user: RMUser
    var status: TimeStampStatus?
    var company: RMCompany
    var time: Date
    private var likesCount: Int = 0
    private var commentsCount: Int = 0
    var isLiked: Bool = false
    var isConfirmed: Bool = false
    var likedBy: [RMUser] = [RMUser]()
    
    var likeCountString: String {
        return "\(self.likesCount)"
    }
    
    var commentCountString: String {
        return "\(self.commentsCount)"
    }
    
    init?(with data: [String: Any]) {
        if let idString = data.stringValue(forkey: "id"),
            let statusString = data.stringValue(forkey: "userStatus"),
            let status = TimeStampStatus.init(rawValue: statusString),
            let startTime = data["startTime"] as? Double,
            let userData = data["user"] as? [String: Any],
            let user = RMUser.init(with: userData) {

            if let compData = data["company"] as? [String: Any],
                let comp = RMCompany.init(with: compData) {
                self.company = comp
            } else {
                return nil
            }
            
            self.id = idString
            self.status = status
            self.user = user
            self.details = data.stringValue(forkey: "status") ?? ""
            self.time = Date.init(timeIntervalSince1970: (startTime / 1000))

            self.isConfirmed = data["confirmedByManager"] as? Bool ?? false

            self.likesCount = (data["likeCount"] as? Int) ?? 0
            self.commentsCount = (data["commentCount"] as? Int) ?? 0
            self.isLiked = (data["currentUserLiked"] as? Bool) ?? false
            
        } else {
            return nil
        }
    }
    
    //    func updateLikesCount(_ completion: @escaping () -> Void) {
    //        APIManager.shared.getLikesCount(for: self.id, completion: { (count, id) in
    //            self.likesCount = count
    //            print("Likes \(String(describing: count)) for \(id)")
    //        })
    //    }
    
    //    func updateCommentsCount(_ completion: @escaping () -> Void) {
    //        APIManager.shared.getCommentsCount(for: self.id, completion: { (count, id) in
    //            self.commentsCount = count
    //            print("Likes \(String(describing: count)) for \(id)")
    //            completion()
    //        })
    //    }
    
    //    func getLikeStatus(_ completion: @escaping () -> Void) {
    //        APIManager.shared.getLikeStatus(for: self.id) { (liked, error) in
    //            self.isLiked = liked
    //            completion()
    //        }
    //    }
    
    func updateLikeStatus(_ completion: @escaping ()->Void) {
        self.isLiked = !self.isLiked
        if self.isLiked {
            self.likesCount += 1
        } else {
            if self.likesCount >= 0 {
                self.likesCount -= 1
            }
        }
        if let status = self.status {
            Analytics.shared.trackTimestampLike(with: status)
        }
        APIManager.shared.changeLikeStatus(for: self.id, toStatus: self.isLiked, completion: { (status, error) in
            //             self.isLiked = status
            completion()
        })
    }
    
    func delete(_ completion: @escaping (Bool)->Void) {
        APIManager.shared.delete(timeStampID: self.id) { (success, error) in
            completion(success)
        }
    }
    
    func getLikedBy(_ completion: @escaping ([RMUser])-> Void) {
        APIManager.shared.getLikedBy(for: self.id) { (users, error) in
            self.likedBy = users.uniqueElements
            completion(users)
        }
    }
    
    func increaseCommentCount(by: UInt) {
        self.commentsCount += 1
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? RMTimestamp {
            return self.id == rhs.id
        }
        return false
    }

    func getConfirmedText() -> String {
        var text = ""
        if !self.isConfirmed {
            text = ""
        } else {
            // If current user is manager
            if RMUser.isCurrentRoleManager() {
                // If current user is same user
                if self.user.isCurrentUser() {
                    text = ""
                } else {
                    if user.isFromSameTeam {
                        // if user is from same team - show "Confirmed"
                        text = "Confirmed".localized
                    } else {
                        // if user is from other team - Hide
                        text = ""
                    }
                }
            } else {
                // If Current user is not manager
                if user.isManager {
                    // if user is manager
                    text = ""
                } else if !user.isManager &&
                    user.isFromSameTeam {
                    // if user is not manager and user is from same team
                    text = "\(user.manager?.name ?? "") \("Confirmed".localized)"
                } else {
                    // if user is not manager and user is from other team
                    text = ""
                }
            }
        }
        return text
    }
    
}
