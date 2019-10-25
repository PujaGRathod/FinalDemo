//
//  TimeStampAPICalls.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Alamofire

//MARK: - User Timeline
extension APIManager {
    func getTimeline(for userid: String? = nil, at page: Int, size: Int = 20, completion: @escaping ([RMTimestamp], Error?, Pagination?)->Void) -> APIRequest? {
        func complete(result: [RMTimestamp], error: Error?, pagination: Pagination) {
            DispatchQueue.main.async {
                completion(result, error, pagination)
            }
        }
        var params: Parameters = [
            "size": size,
            "page": page
        ]
        var apiName = "/timestamp/getByUser"
        if let id = userid {
            params["id"] = id
            apiName = "/timestamp/getByUser"
        } else {
            apiName = "timestamp/getFollowByMeUser"
        }
        
        return self.makeGETRequest(with: apiName, parameters: params) { (response) in
            var stamps = [RMTimestamp]()
            if let error = response.error {
                complete(result: stamps, error: error, pagination: Pagination())
            } else if let result = response.result?["content"] {
                if let list = result as? [[String: Any]] {
                    for data in list {
                        if let timeStamp = RMTimestamp.init(with: data) {
                            stamps.append(timeStamp)
                        }
                    }
                }
                var pagination = Pagination()
                pagination.currentPage = (response.result?["number"] as? Int) ?? 0
                pagination.totalRecords = (response.result?["totalElements"] as? Int) ?? 0
                pagination.totalPages = (response.result?["totalPages"] as? Int) ?? 0
                pagination.pageSize = (response.result?["size"] as? Int) ?? 20
                complete(result: stamps, error: nil, pagination: pagination)
            } else {
                //                complete(result: stamps, error: NSError.error(with: "Unknown error!".localized), pagination: Pagination())
                complete(result: stamps, error: nil, pagination: Pagination())
            }
        }
    }
    
    func getLikesCount(for timeStampID: String, completion: @escaping ((Int, String)->Void)) {
        func complete(result: Int) {
            DispatchQueue.main.async {
                completion(result, timeStampID)
            }
        }
        _ = self.makeGETRequest(with: "timestamp/likeCount:\(timeStampID)", parameters: nil) { (response) in
            if let result = response.result?["count"] as? Int {
                complete(result: result)
            } else {
                complete(result: 0)
            }
        }
    }
    
    func getCommentsCount(for timeStampID: String, completion: @escaping ((Int, String)->Void)) {
        func complete(result: Int) {
            DispatchQueue.main.async {
                completion(result, timeStampID)
            }
        }
        _ = self.makeGETRequest(with: "timestamp/commentCount:\(timeStampID)", parameters: nil) { (response) in
            if let result = response.result?["count"] as? Int {
                complete(result: result)
            } else {
                complete(result: 0)
            }
        }
    }
    
    func changeLikeStatus(for timeStampID: String, toStatus: Bool, completion: @escaping (Bool, Error?)->Void) {
        if toStatus {
            _ = self.makeGETRequest(with: "timestamp/like:\(timeStampID)", parameters: nil) { (response) in
                DispatchQueue.main.async {
                    if let _ = response.result {
                        completion(true, nil)
                    } else {
                        print("like action failed!")
                        completion(false, NSError.error(with: "request failed!".localized))
                    }
                }
            }
        } else {
            _ = self.makeGETRequest(with: "timestamp/unlike:\(timeStampID)", parameters: nil) { (response) in
                DispatchQueue.main.async {
                    if let _ = response.result?.stringValue(forkey:  "message") {
                        completion(true, nil)
                    } else {
                        print("unlike action failed!")
                        completion(false, NSError.error(with: "request failed!".localized))
                    }
                }
            }
        }
    }
    
    func getLikeStatus(for timeStampID: String, completion: @escaping (Bool, Error?)->Void) {
        _ = self.makeGETRequest(with: "timestamp/liked:\(timeStampID)", parameters: nil) { (response) in
            DispatchQueue.main.async {
                if let result = response.result?["data"] as? Bool {
                    completion(result, nil)
                } else {
                    print("get like status failed!")
                    completion(false, NSError.error(with: "request failed!".localized))
                }
            }
        }
    }
    
    func delete(timeStampID: String, completion: @escaping (Bool, Error?)->Void) {
        _ = self.makeDELETERequest(with: "timestamp/\(timeStampID)", parameters: nil) { (response) in
            DispatchQueue.main.async {
                if let _ = response.result?.stringValue(forkey: "data") {
                    completion(true, nil)
                } else {
                    print("delete timestamp failed!")
                    completion(false, NSError.error(with: "request failed!".localized))
                }
            }
        }
    }
    
    func getLikedBy(for timeStampID: String, _ completion: @escaping ([RMUser], Error?) -> Void) {
        _ = self.makeGETRequest(with: "timestamp/likes:\(timeStampID)", parameters: nil) { (response) in
            DispatchQueue.main.async {
                var users = [RMUser]()
                if let result = response.result?["data"] as? [[String: Any]] {
                    for data in result {
                        if let userData = data["user"] as? [String: Any],
                            let user = RMUser.init(with: userData),
                            !users.contains(user) {
                            users.append(user)
                        }
                    }
                    completion(users, nil)
                } else {
                    completion(users, NSError.error(with: "request failed!".localized))
                }
            }
        }
    }
    
    func addComment(_ comment:String, for timeStampID: String, completion: @escaping (Error?)-> Void) {
        func complete(with error: Error?) {
            DispatchQueue.main.async {
                completion(error)
            }
        }
        
        let param: Parameters = [
            "userTimeStampId": timeStampID,
            "comment": comment
        ]
        _ = self.makePOSTRequest(with: "timestamp/comment", parameters: param) { (response) in
            if let error = response.error {
                complete(with: error)
            } else if let _ = response.result?.stringValue(forkey:  "message") {
                complete(with: nil)
            } else {
                complete(with: NSError.error(with: "Unknown error!".localized))
            }
        }
    }
    
    func getComments(for timeStampID: String, completion: @escaping ([RMTimestampComment], Error?)->Void) {
        func complete(result: [RMTimestampComment], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        
        let param: Parameters = [
            "timeStampId": timeStampID
        ]
        _ = self.makeGETRequest(with: "timestamp/comment", parameters: param) { (response) in
            
            var stamps = [RMTimestampComment]()
            if let error = response.error {
                complete(result: stamps, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let timeStamp = RMTimestampComment.init(with: data) {
                        stamps.append(timeStamp)
                    }
                }
                complete(result: stamps, error: nil)
            } else {
                complete(result: stamps, error: NSError.error(with: "Unknown error!".localized))
            }
        }
    }
    
}

// MARK: - Time Stamp
extension APIManager {
    
    struct CompanyModel {
        struct companies {
            struct request {
                var page: Int?
                var allPages: Bool = false
            }
            struct response {
                var companies: [RMCompany] = []
            }
        }
        
        struct search {
            struct request {
                var query: String?
                var latitude: Double?
                var longitude: Double?
            }
            struct response {
                var companies: [RMCompany] = []
            }
        }
    }
    
    struct TimestampAPI {
        struct getTimestamp {
            struct request {
                var id: String = ""
            }
            struct response {
                var error: Error?
                var timestamp: RMTimestamp?
            }
        }
    }
    
    func confirmAllTimeStamp(for userid: String, _ completion: @escaping () -> Void) {
        _ = self.makeGETRequest(with: "timestamp/confirmAllByManager?userId=\(userid)", { (response) in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    func confirmTimeStamp(_ timeStamp: RMTimestamp, _ completion: @escaping () -> Void) {
        _ = self.makeGETRequest(with: "timestamp/confirmByManager?id=\(timeStamp.id)&userId=\(timeStamp.user.id)", { (response) in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    func addTimestamp(with status: TimeStampStatus, withComment comment: String, at location: RMCompany, completion: @escaping (Error?)->Void) {
        var param: Parameters = [
            "locationId": location.id,
            "userStatus": status.rawValue
        ]
        
        if comment.trimString() != "" {
            param["status"] = comment.trimString()
        }
        
        _ = self.makePOSTRequest(with: "timestamp", parameters: param, { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        })
    }
    
    func loadCompanies(request: CompanyModel.companies.request, responseClosure:@escaping ((CompanyModel.companies.response)->Void)) {
        var apiName = "company"
        if request.allPages {
            apiName += "/all"
        }
        _ = self.makeGETRequest(with: apiName) { (rawResponse) in
            var response = CompanyModel.companies.response()
            if let rawCompanies = rawResponse.result?["data"] as? [[String: Any]] {
                for rawCompany in rawCompanies {
                    if let company: RMCompany = RMCompany(with: rawCompany),
                        company.locationType != .other,
                        company.deleted == false {
                        response.companies.append(company)
                    }
                }
            }
            responseClosure(response)
        }
    }
    
    func searchCompany(request: CompanyModel.search.request, responseClosure: @escaping ((CompanyModel.search.response)->Void)) -> APIRequest? {
//        var apiName = "company/search"
        var params: [String: Any] = [:]
//        var params: [String] = [String]()
        if let query = request.query?.trimString(),
            query != "" {
//            params.append("q=\(query)")
            params["text"] = query
        }
        
        if let lat = request.latitude {
//            params.append("lat=\(lat)")
            params["lat"] = lat
        }
        
        if let lon = request.longitude {
//            params.append("lat=\(lon)")
            params["lon"] = lon
        }

//        if params.count > 0 {
//            apiName.append("?")
//            apiName.append(params.joined(separator: "&"))
//        }

        if params.keys.count > 0 {
            return self.makePOSTRequest(with: "company/search", parameters: params, { (rawResponse) in
                var response = CompanyModel.search.response()
                if let rawCompanies = rawResponse.result?["data"] as? [[String: Any]] {
                    for rawCompany in rawCompanies {
                        if let company: RMCompany = RMCompany(with: rawCompany),
                            company.locationType != .other,
                            company.deleted == false {
                            response.companies.append(company)
                        }
                    }
                }
                response.companies = APIManager.shared.sortCompanyWithDistance(list: response.companies)
                DispatchQueue.main.async {
                    responseClosure(response)
                }
            })
        } else {
        return self.makeGETRequest(with: "company/all") { (rawResponse) in
            var response = CompanyModel.search.response()
            if let rawCompanies = rawResponse.result?["data"] as? [[String: Any]] {
                for rawCompany in rawCompanies {
                    if let company: RMCompany = RMCompany(with: rawCompany),
                        company.locationType != .other,
                        company.deleted == false {
                        response.companies.append(company)
                    }
                }
                response.companies = APIManager.shared.sortCompanyWithDistance(list: response.companies)
                DispatchQueue.main.async {
                    responseClosure(response)
                }
            }
        }
        }
    }

    func getTimestampDetails(request: TimestampAPI.getTimestamp.request, responseClosure: @escaping (TimestampAPI.getTimestamp.response)->Void) {
        _ = self.makeGETRequest(with: "timestamp/getById", parameters: [ "id": request.id ], { (apiResponse) in
            var response = TimestampAPI.getTimestamp.response()
            if let error = apiResponse.error {
                response.error = error
            } else if let result = apiResponse.result {
                if let timeStamp = RMTimestamp.init(with: result) {
                    response.timestamp = timeStamp
                }
            }
            responseClosure(response)
        })
    }
}
