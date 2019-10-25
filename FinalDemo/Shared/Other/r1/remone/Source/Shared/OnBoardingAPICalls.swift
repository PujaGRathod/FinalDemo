//
//  OnBoardingAPICalls.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Alamofire

// MARK: - On Boarding and Login
extension APIManager {
    func loginUser(with email: String, password: String, _ completion: @escaping (RMUser?, Bool, Error?) -> Void) {
        let params = ["email": email,
                      "password": password]
        _ = self.makePOSTRequest(with: LoginAPIURL, parameters: params) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(nil, false, error)
                } else {
                    if let token = response.result?.stringValue(forkey:  "token") {
                        if let userData = response.result?["user"] as? [String: Any],
                            let user = RMUser.init(with: userData) {
                            self.loginSession = RMLoginSession.createSession(with: token, user: user)
                            completion(self.loginSession?.user, true, nil)
                        } else {
                            self.loginSession = nil
                            completion(nil, false, NSError.error(with: "Login failed!".localized))
                        }
                    } else {
                        self.loginSession = nil
                        completion(nil, false, NSError.error(with: "Login failed! Please check email and password.".localized))
                    }
                }
            }
        }
    }

    func forgotPassword(for email: String, completion: @escaping (Bool, Error?)->Void) {
        _ = makeGETRequest(with: "auth/forgotpassword?email=\(email)", { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(false, error)
                } else {
                    var message = ""
                    if let success = response.result?["success"] as? Bool,
                        success == true {
                        completion(true, nil)
                    } else {
                        if let data = response.result?.stringValue(forkey: "data") {
                            message = data
                        } else {
                            message = "request failed!"
                        }
                        completion(false, NSError.error(with: message))
                    }
                }
            }
        })
    }

    func fetchDepartmentList(_ completion: @escaping ([RMDepartment], Error?) -> Void) {
        _ = self.makeGETRequest(with: "department/all") { (response) in
            DispatchQueue.main.async {
                var departments = [RMDepartment]()
                if let error = response.error {
                    completion(departments, error)
                } else {
                    if let departmentList = response.result?["data"] as? [[String: Any]] {
                        for depData in  departmentList {
                            if let dept = RMDepartment.init(with: depData) {
                                departments.append(dept)
                            }
                        }
                        completion(departments, nil)
                    } else {
                        completion(departments, NSError.error(with: "No data found!".localized))
                    }
                }
            }
        }
    }

    func fetchPositionList(_ completion: @escaping ([RMPosition], Error?) -> Void) {
        _ = self.makeGETRequest(with: "position/all") { (response) in
            DispatchQueue.main.async {
                var positions = [RMPosition]()
                if let error = response.error {
                    completion(positions, error)
                } else {
                    if let positionList = response.result?["data"] as? [[String: Any]] {
                        for posData in  positionList {
                            if let pos = RMPosition.init(with: posData) {
                                positions.append(pos)
                            }
                        }
                        completion(positions, nil)
                    } else {
                        completion(positions, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func fetchSkillList(_ completion: @escaping ([RMSkill], Error?) -> Void) {
        _ = self.makeGETRequest(with: "skill/all") { (response) in
            DispatchQueue.main.async {
                var skills = [RMSkill]()
                if let error = response.error {
                    completion(skills, error)
                } else {
                    if let skillList = response.result?["data"] as? [[String: Any]] {
                        for skillData in  skillList {
                            if let skill = RMSkill.init(with: skillData) {
                                skills.append(skill)
                            }
                        }
                        completion(skills, nil)
                    } else {
                        completion(skills, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func fetchCompanyList(_ completion: @escaping ([RMCompany], Error?) -> Void) {
        _ = self.makeGETRequest(with: "company/all") { (response) in
            DispatchQueue.main.async {
                var companies = [RMCompany]()
                if let error = response.error {
                    completion(companies, error)
                } else {
                    if let companyList = response.result?["data"] as? [[String: Any]] {
                        for compData in  companyList {
                            if let comp = RMCompany.init(with: compData),
                                comp.locationType != .other {
                                companies.append(comp)
                            }
                        }
                        completion(companies, nil)
                    } else {
                        completion(companies, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func fetchLocationList(_ completion: @escaping ([RMOffice], Error?) -> Void) {
        _ = self.makeGETRequest(with: "company/all") { (response) in
            DispatchQueue.main.async {
                var companies = [RMOffice]()
                if let error = response.error {
                    completion(companies, error)
                } else {
                    if let companyList = response.result?["data"] as? [[String: Any]] {
                        for compData in  companyList {
                            if let comp = RMOffice.init(with: compData),
                                comp.locationType != .other,
                                comp.deleted == false {
                                companies.append(comp)
                            }
                        }
                        completion(companies, nil)
                    } else {
                        completion(companies, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func fetchActualCompanyList(_ completion: @escaping ([RMCompany], Error?) -> Void) {
        _ = self.makeGETRequest(with: "actualCompany/all") { (response) in
            DispatchQueue.main.async {
                var companies = [RMCompany]()
                if let error = response.error {
                    completion(companies, error)
                } else {
                    if let companyList = response.result?["data"] as? [[String: Any]] {
                        for compData in  companyList {
                            if let comp = RMCompany.init(with: compData),
                                comp.locationType != .other,
                                comp.deleted == false {
                                companies.append(comp)
                            }
                        }
                        completion(companies, nil)
                    } else {
                        completion(companies, NSError.error(with:  "No data found!".localized))
                    }
                }
            }
        }
    }

    func uploadImage(_ image: UIImage, _ completion: @escaping (String?, Error?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.7) {
            let urlString = self.makeAPIPath(with: "upload")
            var headers: HTTPHeaders? = nil
            if let token = self.loginSession?.token {
                headers = [
                    "Authorization": "Bearer \(token)",
                    "Content-Type": "application/x-www-form-urlencoded"
                ]
            } else {
                completion(nil, NSError.error(with: "request unauthorized!".localized))
                return
            }
            Alamofire.upload(multipartFormData: { (multipartData) in
                print("Content: \(multipartData.contentType)")
                multipartData.append(imageData, withName: "file.jpg")
            }, to: urlString, headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        } else {
            completion(nil, NSError.error(with: "request is invalid!".localized))
        }

    }

    func uploadImages(_ images: [UIImage], _ completion: @escaping ([String], Error?) -> Void) {
        var imageDatas = [Data]()
        for image in images {
            if let imageData = UIImageJPEGRepresentation(image, 0.7) {
                imageDatas.append(imageData)
            }
        }
        let urlString = self.makeAPIPath(with: "upload/multiple")
        var headers: HTTPHeaders? = nil
        if let token = self.loginSession?.token {
            headers = [
                "Authorization": "Bearer \(token)",
            ]
        } else {
            completion([String](), NSError.error(with: "request unauthorized!".localized))
            return
        }
        Alamofire.upload(multipartFormData: { (multipartData) in
            print("Content: \(multipartData.contentType)")
            for (index, data) in imageDatas.enumerated() {
                multipartData.append(data, withName: "files", fileName: "files\(index).jpg", mimeType: "image/jpg")
            }
        }, to: urlString, headers: headers, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    if let result = response.result.value as? [String: Any],
                        let imagesURLs = result["data"] as? [String] {
                        completion(imagesURLs, nil)
                    } else {
                        completion([String](), NSError.error(with: "Upload failed!".localized))
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                completion([String](), NSError.error(with: "Upload failed!".localized))
            }
        })
    }

//    func updateLocation(at lattitude: Double, longitude: Double, _ completion: @escaping (Bool)->Void) {
//        let params: Parameters = [
//            "lat": lattitude,
//            "lon": longitude
//        ]
//
//        _ = self.makePOSTRequest(with: "user/location", parameters: params, { (response) in
//            DispatchQueue.main.async {
//                if let error = response.error {
//                    print("Error: Updating location \(error.localizedDescription)")
//                    completion(false)
//                } else {
//                    completion(true)
//                }
//            }
//        })
//    }

}
