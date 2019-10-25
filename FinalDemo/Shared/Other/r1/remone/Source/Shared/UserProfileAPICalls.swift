//
//  UserProfileAPICalls.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Alamofire

extension APIManager{
    func uploadProfileImage(_ image: UIImage, _ completion: @escaping (Any?, Error?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.7) {
            let urlString = self.makeAPIPath(with: "user/profilePic")
            var headers: HTTPHeaders? = nil
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)",
                ]
            } else {
                completion(nil, NSError.error(with: "request unauthorized!".localized))
                return
            }
            Alamofire.upload(multipartFormData: { (multipartData) in
                print("Content: \(multipartData.contentType)")
                multipartData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
            }, to: urlString, headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        completion(response,nil)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        } else {
            completion(nil, NSError.error(with: "request is invalid!".localized))
        }
    }

    func uploadCoverImage(_ image: UIImage, _ completion: @escaping (Any?, Error?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.7) {
            let urlString = self.makeAPIPath(with: "user/coverPic")
            var headers: HTTPHeaders? = nil
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)",
                ]
            } else {
                completion(nil, NSError.error(with: "request unauthorized!".localized))
                return
            }
            Alamofire.upload(multipartFormData: { (multipartData) in
                print("Content: \(multipartData.contentType)")
                multipartData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
            }, to: urlString, headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        completion(response,nil)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        } else {
            completion(nil, NSError.error(with: "request is invalid!".localized))
        }
    }

    func updateUserDetailSettings(with params: Parameters,completion: @escaping (Error?)->Void) {
        let param: Parameters = params
        _ = self.makePOSTRequest(with: "user/setting", parameters: param, { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        })
    }


    func updateUserProfileDetail(with params: Parameters,completion: @escaping (Error?)->Void) {
        _ = APIManager.shared.makePOSTRequest(with: "user/detail", parameters: params) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    let session = APIManager.shared.loginSession
                    session?.save()
                    completion(nil)
                }
            }
        }
    }

    func updateUserSkills(with skills: [String],completion: @escaping (Error?)->Void) {
        let param: [String: Any] = [
            "skills": skills
        ]
        _ = APIManager.shared.makePOSTRequest(with: "user/skills", parameters: param) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    let session = APIManager.shared.loginSession
                    session?.save()
                    completion(nil)
                }
            }
        }
    }

    //user/followers
    func getFollowersList(_ completion: @escaping ([RMFollowers], Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/followers") { (response) in
            DispatchQueue.main.async {
                var followers = [RMFollowers]()
                if let error = response.error {
                    completion(followers, error)
                } else {
                    if let followersList = response.result?["data"] as? [[String: Any]] {
                        for followData in  followersList {
                            if let userDetail = followData["userId"] as? [String: Any],
                                let user = RMUser.init(with: userDetail),
                                let id = followData["id"] as? String {
                                let objRMFollower:RMFollowers = RMFollowers.init(user: user, id: id)
                                followers.append(objRMFollower)
                            }
                        }
                        completion(followers, nil)
                    } else {
                        completion(followers, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func acceptRejectFollowRequest(with params: Parameters,completion: @escaping (Error?)->Void) {
        let param: Parameters = params
        _ = self.makePOSTRequest(with: "user/followstatus", parameters: param, { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        })
    }

    func reportOffice(with params: Parameters,completion: @escaping (String,Error?)->Void) {
        let param: Parameters = params
        _ = self.makePOSTRequest(with: "company/reportoffice", parameters: param, { (response) in
            let message = ""
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(message,error)
                } else {
                    if let message = response.result?["data"] as? String {
                        completion(message,nil)
                    }
                }
            }
        })
    }


    func getPendingFollowers(_ completion: @escaping ([RMFollowers], Error?) -> Void) {
        func complete(result: [RMFollowers], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        _ = self.makeGETRequest(with: "user/pendingfollowers") { (response) in
            DispatchQueue.main.async {
                var followers = [RMFollowers]()
                if let error = response.error {
                    completion(followers, error)
                } else {
                    if let followersList = response.result?["data"] as? [[String: Any]] {
                        for followData in  followersList {
                            if let userDetail = followData["user"] as? [String: Any],
                                let id = followData.stringValue(forkey: "followId") {
                                if let user = RMUser.init(with: userDetail) {
                                    let objRMFollower:RMFollowers = RMFollowers.init(user: user, id: id)
                                    followers.append(objRMFollower)
                                }
                            }
                        }
                        completion(followers, nil)
                    } else {
                        completion(followers, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }


    func followUnfollowRequest(to followerId: String, _ completion: @escaping (Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/follow/\(followerId)") { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else if let _ = response.result {
                    completion(nil)
                } else {
                    completion(NSError.error(with: "Unknown error!".localized))
                }
            }
        }
    }

    func updateUserSettings(setings: [UserSettings: Bool],_ completion: @escaping (Bool) -> Void) {
        var rawSettings: [String: Any] = [:]
        for setting in setings {
            rawSettings[setting.key.rawValue] = setting.value
        }
        _ = APIManager.shared.makePOSTRequest(with: "user/setting", parameters: rawSettings) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    print("Update user settings error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    let session = APIManager.shared.loginSession
                    session?.user.settings = setings
                    session?.save()
                    completion(true)
                }
            }
        }
    }
}


// MARK: - User Profile
extension APIManager {

    func getUnreadCounts(_ completion: @escaping (Int) -> Void) {
        _ = self.makeGETRequest(with: "push/notification/count") { (response) in
            DispatchQueue.main.async {
                if let _ = response.error {
                    completion(-1)
                } else if let data = response.result {
                    if let count = data["count"] as? Int {
                        completion(count)
                    } else {
                        completion(-1)
                    }
                } else {
                    completion(-1)
                }
            }
        }
    }

    func getUserProfile(for id: String, _ completion: @escaping (RMUser?, Error?)->Void) {
        _ = self.makeGETRequest(with: "user/\(id)") { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(nil, error)
                } else if let data = response.result {
                    if let user = RMUser.init(with: data) {
                        completion(user, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, NSError.error(with: "Unknown error!".localized))
                }
            }
        }
    }

    func contactUs(with details: String, _ completion: @escaping (Error?) -> Void ) {
        let param: Parameters = [
            "details": details
        ]
        _ = self.makePOSTRequest(with: "user/contactus", parameters: param, { (response) in
            DispatchQueue.main.async {
                completion(response.error)
            }
        })
    }

    func getFollowingUsers(_ completion: @escaping (([RMUser], Error?)->Void)) {
        func complete(result: [RMUser], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        _ = self.makeGETRequest(with: "user/followedbyme", { (response) in
            var users = [RMUser]()
            if let error = response.error {
                complete(result: users, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let user = RMUser.init(with: data) {
                        users.append(user)
                    }
                }
                complete(result: users, error: nil)
            } else {
                complete(result: users, error: nil)
                //                complete(result: users, error: NSError.error(with: "Unknown error!".localized))
            }
        })
    }
}

// Manager
extension APIManager {

    func getManagers(_ completion: @escaping ([RMUser], Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/manager/all") { (response) in
            DispatchQueue.main.async {
                var managers = [RMUser]()
                if let error = response.error {
                    completion(managers, error)
                } else {
                    if let skillList = response.result?["data"] as? [[String: Any]] {
                        for managerData in  skillList {
                            if let skill = RMUser.init(with: managerData) {
                                managers.append(skill)
                            }
                        }
                        completion(managers, nil)
                    } else {
                        completion(managers, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func set(manager: RMUser, completion: @escaping ((Error?)->Void)) {
        _ = self.makePUTRequest(with: "user/manager/\(manager.id)", parameters: nil) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    if let success = response.result?["success"] as? Bool,
                        success == true {
                        completion(nil)
                    } else {
                        completion(NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func getgardnerProfile(for user: RMUser, completion: @escaping (_ gardnerStyle: DotinAttribute?, _ hollandInsight: DotinAttribute?, _ positiveAtt: DotinAttribute?)->Void) {
        if user.dotinUserID == "" &&
            user.dotinSKey == "" {
            completion(nil, nil, nil)
            return;
        }

        func handleResponse(_ response: [String: Any]?) {
            var gardnerStyle: DotinAttribute? = nil
            var hollands: DotinAttribute? = nil
            var positive: DotinAttribute? = nil
            if let response = response,
                let profileData = response["profiles"] as? [[String: Any]] {
                print("Response: \(response)")
                for profileInfo in profileData {
                    let profile = DotinProfile.init(fromDictionary: profileInfo)
                    for var att in profile.attributes {
                        if "personality_style" == att.name {
                            att.groups = att.groups.filter({ return $0.name == "personality_style" })
                            hollands = att
                        } else if "multiple_intelligence" == att.name {
                            att.groups = att.groups.filter({ return $0.name == "multiple_intelligence" })
                            gardnerStyle = att
                        } else if "dominant_attr" == att.name {
                            att.groups = att.groups.filter({ return $0.name == "dominant_attr" })
                            positive = att
                        } else {

                        }
                    }
                }
            }

            DispatchQueue.main.async {
                completion(gardnerStyle, hollands, positive)
            }
        }

        let credentialData = "\(user.dotinUserID):\(user.dotinSKey)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "authorization": "Basic \(base64Credentials)"
        ]

        //        self.createFullAuthentication {
        Alamofire.request("http://remo-one.dotin.us/users/getUser/v2.0?id=\(user.dotinUserID)&locale=ja_JP",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: headers)
//            .authenticate(user: user.dotinUserID, password: user.dotinSKey, persistence: .none)
            .responseJSON { response in
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    handleResponse(json)
                } else if let data = response.data {
                    let dataString = String(data: data, encoding: .utf8)
                    print("Data: \(String(describing: dataString))")
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                            print("Response: \(json)")
                            handleResponse(json)
                        } else {
                            handleResponse(nil)
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        handleResponse(nil)
                    }
                } else {
                    handleResponse(nil)
                }
        }
    }
}

struct GardnerProfileModel {
    let positiveAttributes: [String] = [String]()
    let gardnerLearningStyle: [String] = [String]()
    let hollandsOccupationalInsights: [String] = [String]()
}
