//
//  APIManager.swift
//  remone
//
//  Created by Arjav Lad on 21/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import Alamofire

struct APIResponse {
    let error: Error?
    let result: [String: Any]?
}

let BaseURLDemo = "http://13.231.92.6:8081/api/v1/"
//let BaseURLDemo_OLD = "http://ec2-13-113-216-60.ap-northeast-1.compute.amazonaws.com:8080/api/v1/"
let BaseURLLive = "https://remoone-manage.netone.co.jp:8443/api/v1/"

struct Pagination {
    var currentPage: Int = 0
    var totalRecords: Int = 0
    var totalPages: Int = 0
    var pageSize: Int = 20
}

class APIManager: NSObject {
    
    struct APIRequest {
        var request: DataRequest?
        func cancel() {
            self.request?.cancel()
        }
    }
    
    static let shared = APIManager()
    let reachablity = NetworkReachabilityManager()
    var loginSession: RMLoginSession?

    var currentUser: RMUser? {
        return self.loginSession?.user
    }

    var isSessionActive: Bool {
        return (self.loginSession != nil)
    }
    
    var isConnectedToInternet: Bool {
        if let isNetworkReachable = self.reachablity?.isReachable,
            isNetworkReachable == true {
            return true
        } else {
            return false
        }
    }
    
    var isUserRegistrationComeplete: Bool {
        return ((self.loginSession?.user.isSignupComplete) ?? false)
    }
    
    override init() {
        self.loginSession = RMLoginSession.getLocalSession()
        super.init()
        self.reachablity?.startListening()
        self.reachablity?.listener = { status in
            if let isNetworkReachable = self.reachablity?.isReachable,
                isNetworkReachable == true {
                print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                print("Internet Connected")
                print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            } else {
                print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                print("Internet Disconnected")
                print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
            }
        }
    }
    
    // MARK: - Base Methods
    func makeAPIPath(with requestString: String) -> String {
        if let bundleID = Bundle.main.bundleIdentifier {
            if bundleID == "com.dev.remoneios" {
                return BaseURLDemo.appending(requestString)
            } else {
                return BaseURLLive.appending(requestString)
            }
        }
        return BaseURLDemo.appending(requestString)
    }

    private func validateResponse(json: [String: Any]) -> String? {
        print("JSON: \(json)") // serialized json response
        if let error = json["error"] as? String {
            return error
        } else if let success = json["success"] as? Bool,
            success == false {
            if let message = json["message"] as? String,
                message != "<null>" {
                return message
            } else if let data = json["data"] as? [String: Any],
                let message = data.stringValue(forkey: "message") {
                return message
            } else  if let data = json.stringValue(forkey: "data"),
                data != "<null>" {
                return data
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func makePOSTRequest(with urlString: String, parameters: Parameters?, _ completion: @escaping (APIResponse) -> Void ) -> APIRequest? {
        if !self.isConnectedToInternet {
            completion(APIResponse.init(error: NSError.error(with: "cannot connect to internet".localized), result: nil))
            return nil
        }
        if urlString.isEmpty {
            completion(APIResponse.init(error: NSError.error(with: "request is invalid!".localized), result: nil))
            return nil
        }

        func handleCorrectResponse(with data: [String: Any]) {
            if let data = data["data"] as? [String: Any] {
                completion(APIResponse.init(error: nil, result: data))
            } else {
                completion(APIResponse.init(error: nil, result: data))
            }
            return
        }

        func wrongResponse(with errorMessage: String?) {
            if let errorMessage = errorMessage {
                completion(APIResponse.init(error: NSError.error(with: errorMessage), result: nil))
            } else {
                completion(APIResponse.init(error: nil, result: nil))
            }
//            completion(APIResponse.init(error: NSError.error(with: errorMessage ?? "request failed!".localized), result: nil))
            return
        }
        
        var headers: HTTPHeaders? = [
            "Accept": "application/json"
        ]
        if urlString != LoginAPIURL {
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)"
                ]
            } else {
                completion(APIResponse.init(error: NSError.error(with: "request unauthorized!".localized), result: nil))
                return nil
            }
        }
        let fullURL = self.makeAPIPath(with: urlString)
        print("Calling POST: \(fullURL)")
        
        var request = APIRequest()
        request.request = Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)") // serialized json response
                if let error = self.validateResponse(json: json) {
                    wrongResponse(with: error)
                } else {
                    handleCorrectResponse(with: json)
                }
            } else if let data = response.data {
                let dataString = String(data: data, encoding: .utf8)
                print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        if let error = self.validateResponse(json: json) {
                            wrongResponse(with: error)
                        } else {
                            handleCorrectResponse(with: json)
                        }
                    } else {
                        wrongResponse(with: nil)
                    }
                } catch {
                    print("Error while converting to json: \(error.localizedDescription)")
                    wrongResponse(with: nil)
                }
            } else {
                wrongResponse(with: nil)
            }
        }
        return request
        
    }
    
    func makeGETRequest(with urlString: String, parameters: Parameters? = nil, getDirectResponse: Bool = false, _ completion: @escaping (APIResponse) -> Void) -> APIRequest? {
        if !self.isConnectedToInternet {
            completion(APIResponse.init(error: NSError.error(with: "cannot connect to internet".localized), result: nil))
            return nil
        }
        
        if urlString.isEmpty {
            completion(APIResponse.init(error: NSError.error(with: "request is invalid!".localized), result: nil))
            return nil
        }
        
        func wrongResponse(with errorMessage: String?) {
            if let errorMessage = errorMessage {
                completion(APIResponse.init(error: NSError.error(with: errorMessage), result: nil))
            } else {
                completion(APIResponse.init(error: nil, result: nil))
            }
            return
        }
        
        var headers: HTTPHeaders? = nil
        if !urlString.contains("auth") {
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)",
                    "Accept": "application/json"
                ]
            } else {
                completion(APIResponse.init(error: NSError.error(with: "request unauthorized!".localized), result: nil))
                return nil
            }
        } else {
            headers = ["Accept": "application/json"]
        }

        func handleCorrectResponse(with data: [String: Any]) {
            completion(APIResponse.init(error: nil, result: data))
            return
        }

        let fullURL = self.makeAPIPath(with: urlString)
        print("Calling GET: \(fullURL)")
//        if let url = URL.init(string: fullURL) {
//            do {
//                let urlReq = try URLRequest.init(url: url, method: HTTPMethod.get, headers: headers)
//                Alamofire.request(<#T##urlRequest: URLRequestConvertible##URLRequestConvertible#>)
//            } catch {
//                print("Url creation error: \(error.localizedDescription)")
//            }
//        }
        var request = APIRequest()
        request.request = Alamofire.request(fullURL, method: .get, parameters: parameters, headers: headers).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)") // serialized json response
                if getDirectResponse {
                    completion(APIResponse.init(error: nil, result: json))
                    return
                }
                if let error = self.validateResponse(json: json) {
                        wrongResponse(with: error)
                } else {
                    if let data = json["data"] as? [String: Any] {
                        handleCorrectResponse(with: data)
                    } else {
                        handleCorrectResponse(with: json)
                    }
                }
            } else if let data = response.data {
                let dataString = String(data: data, encoding: .utf8)
                print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        if getDirectResponse {
                            completion(APIResponse.init(error: nil, result: json))
                            return
                        }
                        if let error = self.validateResponse(json: json) {
                                wrongResponse(with: error)
                        } else {
                            handleCorrectResponse(with: json)
                        }
                    } else {
                        wrongResponse(with: nil)
                    }
                } catch {
                    print("Error while converting to json: \(error.localizedDescription)")
                    wrongResponse(with: nil)
                }
            } else {
                wrongResponse(with: nil)
            }
        }
        return request
    }
    
    func makeDELETERequest(with urlString: String, parameters: Parameters? = nil, _ completion: @escaping (APIResponse) -> Void) -> APIRequest? {
        if urlString.isEmpty {
            completion(APIResponse.init(error: NSError.error(with: "request is invalid!".localized), result: nil))
            return nil
        }
        
        func wrongResponse(with errorMessage: String?) {
            if let errorMessage = errorMessage {
                completion(APIResponse.init(error: NSError.error(with: errorMessage), result: nil))
            } else {
                completion(APIResponse.init(error: nil, result: nil))
            }
            return
        }
        
        var headers: HTTPHeaders? = nil
        if let token = self.loginSession?.token {
            headers = [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json"
            ]
        } else {
            completion(APIResponse.init(error: NSError.error(with: "request unauthorized!".localized), result: nil))
            return nil
        }
        let fullURL = self.makeAPIPath(with: urlString)
        print("Calling DELETE: \(fullURL)")
        
        var request = APIRequest()
        request.request = Alamofire.request(fullURL, method: .delete, parameters: parameters, headers: headers).responseJSON { response in
            func handleCorrectResponse(with data: [String: Any]) {
                completion(APIResponse.init(error: nil, result: data))
                return
            }
            
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)") // serialized json response
                if let error = json["error"] as? String {
                    if error.lowercased() == "<null>" {
                        wrongResponse(with: nil)
                    } else {
                        wrongResponse(with: error)
                    }
                } else if let success = json["success"] as? Bool,
                    success == false {
                    wrongResponse(with: nil)
                } else {
                    if let data = json["data"] as? [String: Any] {
                        handleCorrectResponse(with: data)
                    } else {
                        handleCorrectResponse(with: json)
                    }
                }
            } else if let data = response.data {
                let dataString = String(data: data, encoding: .utf8)
                print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        if let error = json["error"] as? String {
                            wrongResponse(with: error)
                        } else if let success = json["success"] as? Bool,
                            success == false {
                            wrongResponse(with: nil)
                        } else {
                            handleCorrectResponse(with: json)
                        }
                    } else {
                        wrongResponse(with: dataString)
                    }
                } catch {
                    print("Error while converting to json: \(error.localizedDescription)")
                    wrongResponse(with: nil)
                }
            } else {
                wrongResponse(with: nil)
            }
        }
        return request
    }

    func makePUTRequest(with urlString: String, parameters: Parameters?, _ completion: @escaping (APIResponse) -> Void ) -> APIRequest? {
        if !self.isConnectedToInternet {
            completion(APIResponse.init(error: NSError.error(with: "cannot connect to internet".localized), result: nil))
            return nil
        }
        if urlString.isEmpty {
            completion(APIResponse.init(error: NSError.error(with: "request is invalid!".localized), result: nil))
            return nil
        }
        
        func handleCorrectResponse(with data: [String: Any]) {
            if let data = data["data"] as? [String: Any] {
                completion(APIResponse.init(error: nil, result: data))
            } else {
                completion(APIResponse.init(error: nil, result: data))
            }
            return
        }
        
        func wrongResponse(with errorMessage: String?) {
            if let errorMessage = errorMessage {
                completion(APIResponse.init(error: NSError.error(with: errorMessage), result: nil))
            } else {
                completion(APIResponse.init(error: nil, result: nil))
            }
            return
        }
        
        var headers: HTTPHeaders? = [
            "Accept": "application/json"
        ]
        if urlString != LoginAPIURL {
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)"
                ]
            } else {
                completion(APIResponse.init(error: NSError.error(with: "request unauthorized!".localized), result: nil))
                return nil
            }
        }
        let fullURL = self.makeAPIPath(with: urlString)
        print("Calling PUT: \(fullURL)")
        
        var request = APIRequest()
        request.request = Alamofire.request(fullURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)") // serialized json response
                if let error = self.validateResponse(json: json) {
                        wrongResponse(with: error)
                } else {
                    handleCorrectResponse(with: json)
                }
            } else if let data = response.data {
                let dataString = String(data: data, encoding: .utf8)
                print("Data: \(String(describing: dataString))") // original server data as UTF8 string
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        if let error = self.validateResponse(json: json) {
                                wrongResponse(with: error)
                        } else {
                            handleCorrectResponse(with: json)
                        }
                    } else {
                        wrongResponse(with: nil)
                    }
                } catch {
                    print("Error while converting to json: \(error.localizedDescription)")
                    wrongResponse(with: nil)
                }
            } else {
                wrongResponse(with: nil)
            }
        }
        return request
        
    }

    func getDefaultOfficeSearchFilter() {
        OfficeSearchFilter.generateStaticFilter { (filter) in
            OfficeSearchFilter.defaultOfficeSearchFilter = filter
        }
    }

}

