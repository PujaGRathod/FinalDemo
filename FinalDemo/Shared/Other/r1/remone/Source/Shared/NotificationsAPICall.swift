//
//  NotificationsAPICall.swift
//  remone
//
//  Created by Arjav Lad on 07/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case post = "POST"
    case like = "LIKE"
    case comment = "COMMENT"
    case followRequest = "FOLLOW_REQUEST"
    case followRequestAccepted = "REQUEST_ACCEPTED"
    case unknown = ""

    var icon: UIImage? {
        switch self {
            case .comment:
            return #imageLiteral(resourceName: "iconCommentNotification")

        case .like:
           return #imageLiteral(resourceName: "iconLikeNotification")

        default:
            return nil
        }
    }

}

struct NotificationModel: Equatable {
    var id: String = ""
    var actionUserID: String = ""
    var actionUserName: String = ""
    var title: String = ""
    var type: NotificationType = .unknown
    var isRead: Bool = false
    var time: Date? = nil
    var profilePic: URL?
    var timestampId: String?
    
    init() {
        
    }

    static func ==(lhs: NotificationModel, rhs: NotificationModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension APIManager {
    
    func notification(from rawNotification: [String:Any]) -> NotificationModel? {
        if let id = rawNotification.stringValue(forkey: "id"),
            let actionUserID = rawNotification.stringValue(forkey: "by") {

            var url: URL? = nil
            if let profileUrl = rawNotification.stringValue(forkey: "pic") {
                url = URL.init(string: profileUrl)
            }

            var typeData = ""
            if let pushtypeData = rawNotification.stringValue(forkey: "pushType") {
                typeData = pushtypeData
            } else if let pushtypeData = rawNotification.stringValue(forkey: "type") {
                typeData = pushtypeData
            } else {
                return nil
            }
            let type: NotificationType = NotificationType.init(rawValue: typeData) ?? .unknown

            var username = ""
            if let actionUserName = rawNotification.stringValue(forkey: "uname") {
                username = actionUserName
            } else if let actionUserName = rawNotification.stringValue(forkey: "uName") {
                username = actionUserName
            } else {
                return nil
            }

            var title = ""
            if let titleString = rawNotification.stringValue(forkey: "title") {
                title = titleString
            } else if let titleString = ((rawNotification["aps"] as? [String :Any])?["alert"] as? [String: Any])?["title"] as? String {
                title = titleString
            } else {
                return nil
            }

            var model = NotificationModel()
            model.id = id
            model.actionUserID = actionUserID
            model.actionUserName = username
            model.title = title
            model.type = type
            model.isRead = (rawNotification["read"] as? Bool ?? false)
            if let dateTimeStamp = rawNotification["sentOn"] as? TimeInterval {
                model.time = Date.init(timeIntervalSince1970: (dateTimeStamp / 1000))
            }
            model.profilePic = url
            model.timestampId = rawNotification.stringValue(forkey: "tsId") ?? rawNotification.stringValue(forkey: "timeStampId")
            return model
        }
        return nil
    }
    
    func getAllNotifications(at page: Int, size: Int = 20, _ completion: @escaping ([NotificationModel], Error?, Pagination?) -> Void) -> APIRequest? {
        return self.makeGETRequest(with: "push/notification?size=\(size)&page=\(page)", { (response) in
            var notificationsList = [NotificationModel]()
            if let error = response.error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(notificationsList, error, Pagination())
                }
            } else if let result = response.result?["content"] as? [[String: Any]] {
                for resultData in result {
                    if let model = self.notification(from: resultData) {
                        notificationsList.append(model)
                    }
                }
                var pagination = Pagination()
                pagination.currentPage = (response.result?["number"] as? Int) ?? 0
                pagination.totalRecords = (response.result?["totalElements"] as? Int) ?? 0
                pagination.totalPages = (response.result?["totalPages"] as? Int) ?? 0
                pagination.pageSize = (response.result?["size"] as? Int) ?? 20
                DispatchQueue.main.async {
                    completion(notificationsList, nil, pagination)
                }
            } else {
                DispatchQueue.main.async {
                    completion(notificationsList, nil, Pagination())
                }
            }
        })
    }

    func markNotificationAsRead(notification: [NotificationModel], _ completion: @escaping (Error?)->Void) {
        let ids = notification.filter { return !$0.isRead }.map{return $0.id}
        if ids.count <= 0 {
            completion(nil)
            return;
        }
        let params: [String: Any] = [
            "ids": ids
        ]
        _ = self.makePOSTRequest(with: "push/markasread", parameters: params, { (response) in
            DispatchQueue.main.async {
                completion(response.error)
            }
        })
    }
}
