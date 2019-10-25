//
//  SearchPeopleAPICalls.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Alamofire

// Search People
extension APIManager {

    func searchPeople(with filter: SearchPeopleFilter, completion: @escaping ([SearchPeopleModel], Error?)-> Void) {
        var params: [String: Any] = [:]
        params["inHouse"] = filter.showInHouseOnly
        params["teamMember"] = filter.showTeamMembersOnly
        params["name"] = filter.searchKeyword

        if let selectedStatus = filter.selectedStatus {
            params["userStatus"] = selectedStatus.rawValue
        }

        if let position = filter.position {
            params["positionId"] = position.id
        }

        params["personalMatch"] = filter.showOnlyGoodAffinityPeople

        if let department = filter.department {
            params["departmentId"] = department.id
        }

        if let company = filter.company {
            params["companyId"] = company.id
        }

        if filter.skills.count > 0 {
            params["skillIds"] = filter.skills.map({return $0.id})
        }

        if let place = filter.location {
            params["locationId"] = place.id
        }
        _ = self.makePOSTRequest(with: "user/search", parameters: params, { (response) in
            var usersList = [SearchPeopleModel]()
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(usersList, error)
                }
            } else if let result = response.result?["data"] as? [[String: Any]] {
                print(result)
                for userData in result {
                    if let user = RMUser.init(with: userData) {
                        if user.shouldShowUser {
                            var userModel = SearchPeopleModel.init(with: user)
                            if var timeStampData = userData["usersLatestTimestamp"] as? [String: Any] {
                                if let _ = timeStampData["user"] as? [String: Any] {
                                    
                                } else {
                                    timeStampData["user"] = userData
                                }
                                userModel.timestamp = RMTimestamp.init(with: timeStampData)
                            }
                            usersList.append(userModel)
                        } else {
                            print("Don't show: \(user.id)")
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(usersList, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(usersList, nil)
                }
            }
        })
    }

    func getSearchPeopleHistory(_ completion: @escaping ([SearchPeopleFilter], Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/search/history", { (response) in
            var historyList = [SearchPeopleFilter]()
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(historyList, error)
                }
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for historyData in result {
                    historyList.append(SearchPeopleFilter.createFilter(with: historyData))
                }
                DispatchQueue.main.async {
                    completion(historyList, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(historyList, nil)
                }
            }
        })
    }

    func deleteDeviceToken(_ token: String, completion: @escaping ()-> Void) {
        if token.count <= 0 {
            print("Device token incorrect: \(token)")
            completion()
            return
        }
        _ = self.makePUTRequest(with: "user/logout/\(token)", parameters: nil, { (response) in
            if let error = response.error {
                print("Device Token not deleted: \(error.localizedDescription)")
            } else {
                print("Device Token deleted")
            }
            DispatchQueue.main.async {
                completion()
            }
        })
    }

    func changeFavUserStatus(for userid: String, completion: @escaping (Error?)-> Void) {
        _ = self.makeGETRequest(with: "user/fav/\(userid)", { (response) in
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(error)
                }
            } else if let _ = response.result {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        })
    }

    func checkFavStatus(for userid: String, completion: @escaping (Bool)-> Void) {
        _ = self.makeGETRequest(with: "user/checkFavStatus/\(userid)", { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(false)
                }
            } else if let result = response.result?["data"] as? Bool {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        })
    }

    func addDeviceToken(_ token: String) {
        if token.count <= 0 {
            print("Device token incorrect: \(token)")
            return
        }
        _ = self.makePUTRequest(with: "user/udid/\(token)", parameters: nil, { (response) in
            if let error = response.error {
                print("Device Token not updated: \(error.localizedDescription)")
            } else {
                print("Device Token updated")
            }
        })
    }

    func getFavUsers(_ completion: @escaping ([SearchPeopleModel], Error?)->Void) {
        _ = self.makeGETRequest(with: "user/fav", parameters: nil, getDirectResponse: false, { (response) in
            var users = [SearchPeopleModel]()
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(users, error)
                }
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for resultUser in result {
                    if let userDetail = resultUser["favouriteUser"] as? [String: Any],
                        let user = RMUser.init(with: userDetail) {
                        if user.shouldShowUser {
                            var peopleModel = SearchPeopleModel.init(with: user)
                            if let timeStampDetail = resultUser["userTimestamp"] as? [String: Any] {
                                peopleModel.timestamp = RMTimestamp.init(with: timeStampDetail)
                            }
                            users.append(peopleModel)
                        } else {
                            print("Don't show: \(user.id)")
                        }
                    } else {
                        print("Wrong response: \(resultUser)")
                    }
                }
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            }
        })
    }

    func searchPeople(near latitude: Double, longitude: Double, _ completion: @escaping ([SearchPeopleModel], Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/search/geo?lat=\(latitude)&lon=\(longitude)", parameters: nil, { (response) in
            var users = [SearchPeopleModel]()
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(users, error)
                }
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for userData in result {
                    if let user = RMUser.init(with: userData) {
                        if user.shouldShowUser {
                            var userModel = SearchPeopleModel.init(with: user)
                            if var timeStampData = userData["usersLatestTimestamp"] as? [String: Any] {
                                if let _ = timeStampData["user"] as? [String: Any] {
                                    
                                } else {
                                    timeStampData["user"] = userData
                                }
                                userModel.timestamp = RMTimestamp.init(with: timeStampData)
                            }
                            users.append(userModel)
                        } else {
                            print("Don't show: \(user.id)")
                        }
                    } else {
                        print("Wrong response: \(userData)")
                    }
                }
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            }
        })
    }

    func createFullAuthentication(_ completion: @escaping ()-> Void) {
        Alamofire.request("http://sandbox.dotin.us/",
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil) .authenticate(user: "", password: "").responseJSON { response in
                            DispatchQueue.main.async {
                                completion()
                            }
        }
    }

    func matchDotinUser(with otherUsers: [SearchPeopleModel], completion: @escaping ([SearchPeopleModel]) -> Void) {
        func handleCorrectResponse(_ response: [[String: Any]]) {
            print("Correct Response: \(response)")
            var otherUsersList = otherUsers
            for result in response {
                if let otherUserId = result.stringValue(forkey: "secondUserId") {
                    for (index, usermodel) in otherUsers.enumerated() {
                        if usermodel.user.dotinUserID == otherUserId {
                            var model = usermodel
                            model.score = result["score"] as? Double ?? 0
                            otherUsersList[index] = model
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(otherUsersList)
            }
        }

        func handleError() {
            DispatchQueue.main.async {
                completion(otherUsers)
            }
        }

        if let user = APIManager.shared.loginSession?.user {
            let username = user.dotinUserID
            let skey = user.dotinSKey
            if user.dotinUserID != "" {
                var parameters = [user.dotinUserID]
                for model in otherUsers {
                    if model.user.dotinUserID != "",
                        model.user.dotinUserID != user.dotinUserID {
                        parameters.append(model.user.dotinUserID)
                    }
                }
                print(parameters)
                if JSONSerialization.isValidJSONObject(parameters) {
                    do {
                        let credentialData = "\(username):\(skey)".data(using: String.Encoding.utf8)!
                        let base64Credentials = credentialData.base64EncodedString(options: [])
                        let headers = [
                            "Content-Type": "application/json",
                            "Authorization": "Basic \(base64Credentials)"
                        ]
                        let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                        var request = URLRequest.init(url: URL.init(string: "http://remo-one.dotin.us/users/match/v1.0")!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
                        request.httpMethod = "POST"
                        request.allHTTPHeaderFields = headers
                        request.httpBody = postData
//                        self.createFullAuthentication {
                            Alamofire.request(request).responseJSON { response in
                                if let json = response.result.value as? [[String: Any]] {
                                    print("JSON: \(json)") // serialized json response
                                    handleCorrectResponse(json)
                                } else if let data = response.data {
                                    let dataString = String(data: data, encoding: .utf8)
                                    print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any]] {
                                            print("Response: \(json)")
                                            handleCorrectResponse(json)
                                        } else {
                                            handleError()
                                            return;
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                        handleError()
                                    }
                                } else {
                                    handleError()
                                }
//                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                        handleError()
                        return;
                    }
                } else {
                    handleError()
                    return;
                }
            } else {
                handleError()
                return;
            }
        } else {
            handleError()
            return;
        }
    }
}

