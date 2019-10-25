//
//  RMUser.swift
//  remone
//
//  Created by Arjav Lad on 21/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import MapKit
enum FollowStatusType: String {
    case notfollowing = "NOT_FOLLOWING"
    case following = "FOLLOWING"
    case requested = "REQUESTED"
    case unknown = "UNKNOWN"

    var getTheme: RMFollowButtonTheme {
        switch self {
        case .following:
            return RMFollowButtonThemeFollowing()

        case .requested:
            return RMFollowButtonThemeRequested()

        case .notfollowing:
            return RMFollowButtonThemeUnfollow()

        default:
            return RMFollowButtonThemeUnknown()
        }
    }

    var getNewStatus: FollowStatusType {
        switch self {
        case .following:
            return .notfollowing

        case .requested:
            return .notfollowing

        case .notfollowing:
            return .requested

        default:
            return .unknown
        }
    }
}

enum DisclosureSettings: String {
    case name = "discloseName"
    case ruby = "discloseRuby"
    case position = "disclosePosition"
    case department = "discloseDepartment"
    case company = "discloseCompany"
    case all = "discloseAll"
}

enum UserSettings: String {
    case disclosureInfo = "disclosureInfo"
    case name = "name"
    case ruby = "ruby"
    case title = "title"
    case department = "department"
    case position = "position"
    case company = "company"
    case email = "email"
    case mobileNo = "mobileNo"
    case phoneNo = "phoneNo"
    case skill = "skill"
}

enum UserRole: String {
    case user = "ROLE_USER"
    case admin = "ROLE_SUPER_ADMIN"
    case moderator = "ROLE_MODERATOR"
    case manager = "ROLE_MANAGER"
}

class RMUser: NSObject, NSCoding {
    
    var name: String = ""
    var sparkid: String = ""
    let id: String
    var username: String = ""
    var email: String
    var ruby: String = ""
    var position: RMPosition?
    var department: RMDepartment?
    var company: RMCompany?
    var manager: RMUser?
    var skills: [RMSkill] = [RMSkill]()
    var disclosureSettings: [DisclosureSettings: Bool] = [:]
    var settings: [UserSettings: Bool] = [:]
    var isSignupComplete: Bool = false
    var images: [ImageObject] = [ImageObject]()
    let isEnabled: Bool
    var coverPicture: URL?
    var profilePicture: URL?
    var info: String = ""
    var mobileNo: String = ""
    var phoneNo: String = ""
    var role: UserRole = .user
    var followStatus: FollowStatusType = .unknown
    var dotinUserID: String = ""
    var dotinSKey: String = ""
    var userLocation :OfficeLocation?
    var positiveAttributes: DotinAttribute?
    var hollandInsights: DotinAttribute?
    var gardnerLearningStyle: DotinAttribute?
    
    var shouldShowUser: Bool {
        if self.isCurrentUser() {
            return true
        } else if self.isInHouseMember {
            return true
        } else if self.followStatus == .following {
            return true
        } else {
            if self.settings[.disclosureInfo] == true {
                return true
            }
            return false
        }
    }

    var isManager: Bool {
        return (self.role == .manager)
    }

    var isFromSameTeam: Bool {
        if let user = APIManager.shared.loginSession?.user {
            if self.isCurrentUser() {
                return true
            } else if user.isManager {
                return (self.manager == user)
            } else if self.isManager {
                return (self == user.manager)
            }
            return (self.manager == user.manager)
        }
        return false
    }

    var isInHouseMember: Bool {
        if let user = APIManager.shared.loginSession?.user {
            if self.isCurrentUser() {
                return true
            }
            return user.company == self.company
        }
        return false
    }

    class func isCurrentRoleManager() -> Bool {
        if let user = APIManager.shared.loginSession?.user {
            return user.isManager
        }
        return false
    }

    func isCurrentUser() -> Bool {
        if let user = APIManager.shared.loginSession?.user {
            return (user == self)
        }
        return false
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.sparkid, forKey: "sparkid")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.info, forKey: "info")
        aCoder.encode(self.mobileNo, forKey: "mobileNo")
        aCoder.encode(self.phoneNo, forKey: "phoneNo")
        aCoder.encode(self.ruby, forKey: "ruby")
        let imageurls = self.images.map { (object) -> URL? in
            if let url = object.url {
                return url
            } else {
                return nil
            }
        }
        aCoder.encode(imageurls, forKey: "images")
        aCoder.encode(self.isEnabled, forKey: "enabled")

        aCoder.encode(self.dotinUserID, forKey: "dotinid")
        aCoder.encode(self.dotinSKey, forKey: "skey")

        var userDetail: [String: Any] = [:]
        for setting in self.disclosureSettings {
            userDetail[setting.key.rawValue] = setting.value
        }
        userDetail["signupFinished"] = self.isSignupComplete
        userDetail["sparkid"] = self.sparkid
        aCoder.encode(userDetail, forKey: "userDetail")

        var userSettings: [String: Any] = [:]
        for setting in self.settings {
            userSettings[setting.key.rawValue] = setting.value
        }
        aCoder.encode(userSettings, forKey: "userSetting")

        if let rawData = self.position?.getRawData() {
            aCoder.encode(rawData, forKey: "position")
        }

        if let rawData = self.department?.getRawData() {
            aCoder.encode(rawData, forKey: "department")
        }

        var skillsData: [[String: Any]] = [[:]]
        for skill in self.skills {
            skillsData.append(skill.getRawData())
        }
        aCoder.encode(skillsData, forKey: "skills")

        if let compData = self.company?.getRawData() {
            aCoder.encode(compData, forKey: "company")
        }
        
        if let cover = self.coverPicture {
            aCoder.encode(cover, forKey: "coverPicture")
        }

        if let profile = self.profilePicture {
            aCoder.encode(profile, forKey: "profilePicture")
        }
        
    }

    init?(with data: [String: Any]) {
        
        if let idString = data.stringValue(forkey: "id"),
            let emailString = data.stringValue(forkey: "email"),
            let roleString = data.stringValue(forkey: "role"),
            let role = UserRole.init(rawValue: roleString) {
            
            var coordinates: CLLocationCoordinate2D
            if let lat = data["lat"] as? Double,
                let lon = data["lon"] as? Double {
                coordinates = CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
                self.userLocation = OfficeLocation.init(coordinates: coordinates, address:"")
            }
            
            if let followupString = data.stringValue(forkey: "followStatus"),
                let followType = FollowStatusType.init(rawValue: followupString) {
                self.followStatus = followType
            } else {
                self.followStatus = .unknown
            }

            
            self.id = idString
            self.email = emailString
            self.role = role
            
            if role == .user {
                if let managerData = data["manager"] as? [String: Any] {
                    self.manager = RMUser.init(with: managerData)
                }
            }
            
            if let nameString = data.stringValue(forkey: "name") {
                self.name = nameString
            }
            
            if let sparkId = data.stringValue(forkey: "sparkid") {
                self.sparkid = sparkId
            }
            
            if let rubyString = data.stringValue(forkey: "ruby") {
                self.ruby = rubyString
            }

            if let usernameString = data.stringValue(forkey: "username") {
                self.username = usernameString
            }

            if let imagesData = data["images"] as? [[String: Any]] {
                for imageData in imagesData {
                    if let imageLink = imageData["url"] as? String,
                        let imageURL = URL.init(string: imageLink) {
                        self.images.append(ImageObject(withURL: imageURL))
                    }
                }
            } else {
                self.images = [ImageObject]()
            }

            if let enabled = data["enabled"] as? Bool {
                self.isEnabled = enabled
            } else {
                self.isEnabled = false
            }

            self.skills = [RMSkill]()
            if let skillsList = data["skills"] as? [[String: Any]] {
                for skillData in skillsList {
                    if let skillDict = skillData["skill"] as? [String: Any],
                        let skill = RMSkill.init(with: skillDict) {
                        self.skills.append(skill)
                    }
                }
            }

            if let compData = data["actualCompany"] as? [String: Any],
                let comp = RMCompany.init(with: compData) {
                self.company = comp
            } else {
                if let compData = data["company"] as? [String: Any],
                    let comp = RMCompany.init(with: compData) {
                    self.company = comp
                }
            }
            

            if let disclosureSettingsData = data["userDetail"] as? [String: Any] {
                for (key, value) in disclosureSettingsData {
                    if let set = DisclosureSettings.init(rawValue: key) {
                        if let value = value as? Bool {
                            self.disclosureSettings[set] = value
                        }
                    } else if key == "signupFinished" {
                        if let signup = value as? Bool {
                            self.isSignupComplete = signup
                        } else {
                            self.isSignupComplete = false
                        }
                    } else if key == "name" {
                        self.name = (value as? String) ?? ""
                    }
                    else if key == "sparkid" {
                        self.sparkid = (value as? String) ?? ""
                    }
                    else if key == "ruby" {
                        self.ruby = (value as? String) ?? ""
                    } else if key == "profilePic",
                        let urlString = value as? String {
                        var url = URL.init(string: urlString)
                        if url == nil {
                            url = URL.init(string: (urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? "")
                        }
                        self.profilePicture = url
                    } else if key == "coverPic",
                        let urlString = value as? String {
                        var url = URL.init(string: urlString)
                        if url == nil {
                            url = URL.init(string: (urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) ?? "")
                        }
                        self.coverPicture = url
                    } else if key == "department",
                        let dept = value as? [String: Any] {
                        self.department = RMDepartment.init(with: dept)
                    } else if key == "position",
                        let pos = value as? [String: Any] {
                        self.position = RMPosition.init(with: pos)
                    } else if key == "info",
                        let text = value as? String {
                        self.info = text
                    } else if key == "mobileNo",
                        let text = value as? String {
                        self.mobileNo = text
                    } else if key == "phoneNo",
                        let text = value as? String {
                        self.phoneNo = text
                    } else if key == "dotinid",
                        let text = value as? String {
                        self.dotinUserID = text
                    } else if key == "skey",
                        let text = value as? String {
                        self.dotinSKey = text
                    }
                }
            }

            if let userSettingsData = data["userSetting"] as? [String: Any] {
                for (key, value) in userSettingsData {
                    if let set = UserSettings.init(rawValue: key) {
                        if let value = value as? Bool {
                            self.settings[set] = value
                        }
                    }
                }
            }

        } else {
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        if let idString = aDecoder.getStringValue(for: "id"),
            let emailString = aDecoder.getStringValue(for: "email") {
            self.id = idString
            self.email = emailString

            if let nameString = aDecoder.getStringValue(for: "name") {
                self.name = nameString
            }
            
            if let sparkId = aDecoder.getStringValue(for: "sparkid") {
                self.sparkid = sparkId
            }

            if let text = aDecoder.getStringValue(for: "dotinid") {
                self.dotinUserID = text
            }

            if let text = aDecoder.getStringValue(for: "skey") {
                self.dotinSKey = text
            }

            if let text = aDecoder.getStringValue(for: "info") {
                self.info = text
            }

            if let text = aDecoder.getStringValue(for: "mobileNo") {
                self.mobileNo = text
            }

            if let text = aDecoder.getStringValue(for: "phoneNo") {
                self.phoneNo = text
            }

            if let rubyString = aDecoder.getStringValue(for: "ruby") {
                self.ruby = rubyString
            }

            if let usernameString = aDecoder.getStringValue(for: "username") {
                self.username = usernameString
            }

            if let imagesData = aDecoder.decodeObject(forKey: "images") as? [URL?] {
                for imageURL in imagesData {
                    if let imageURL = imageURL {
                        self.images.append(ImageObject.init(withURL: imageURL))
                    }
                }
            } else {
                self.images = [ImageObject]()
            }

            if let cover = aDecoder.decodeObject(forKey: "coverPicture") as? URL {
                self.coverPicture = cover
            }
            
            if let profile = aDecoder.decodeObject(forKey: "profilePicture") as? URL {
                self.profilePicture = profile
            }
            
            if let dept = aDecoder.decodeObject(forKey: "department") as? [String: Any] {
                self.department = RMDepartment.init(with: dept)
            }

            if let pos = aDecoder.decodeObject(forKey: "position") as? [String: Any]{
                self.position = RMPosition.init(with: pos)
            }

            if let enabled = aDecoder.decodeObject(forKey: "enabled") as? Bool {
                self.isEnabled = enabled
            } else {
                self.isEnabled = false
            }

            self.skills = [RMSkill]()
            if let skillsData = aDecoder.decodeObject(forKey: "skills") as? [[String: Any]]  {
                for skillData in skillsData {
                    if let skill = RMSkill.init(with: skillData) {
                        self.skills.append(skill)
                    }
                }
            }

            if let disclosureSettingsData = aDecoder.decodeObject(forKey: "userDetail") as? [String: Any] {
                for (key, value) in disclosureSettingsData {
                    if let set = DisclosureSettings.init(rawValue: key) {
                        if let value = value as? Bool {
                            self.disclosureSettings[set] = value
                        }
                    }
                    else if key == "sparkid" {
                        if let value = value as? String {
                            self.sparkid = value
                        }
                    }
                    else if key == "signupFinished" {
                        if let signup = value as? Bool {
                            self.isSignupComplete = signup
                        } else {
                            self.isSignupComplete = false
                        }
                    }
                }
            }

            if let userSettingsData = aDecoder.decodeObject(forKey: "userSetting") as? [String: Any] {
                for (key, value) in userSettingsData {
                    if let set = UserSettings.init(rawValue: key) {
                        if let value = value as? Bool {
                            self.settings[set] = value
                        }
                    }
                }
            }

            if let compData = aDecoder.decodeObject(forKey: "company") as? [String: Any],
                let comp = RMCompany.init(with: compData) {
                self.company = comp
            }
        } else {
            return nil
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? RMUser {
            return self.id == rhs.id
        }
        return false
    }
    
}

extension RMUser {
    func followUnfollowUser(_ completion: @escaping (Bool) -> Void) {
        APIManager.shared.followUnfollowRequest(to: self.id, { (error) in
            completion((error == nil))
        })
    }

    func updateProfile(_ completion: @escaping (Bool) -> Void) {
        var rawData: [String: Any] = [
            "name": self.name,
            "ruby": self.ruby
        ]

        if self.sparkid.trimString() != "" {
            rawData["sparkid"] = self.sparkid
        }
        if self.isSignupComplete {
            rawData["signupFinished"] = self.isSignupComplete
        }
        if let pos = self.position {
            rawData["positionId"] = pos.id
        }
        if let dept = self.department {
            rawData["departmentId"] = dept.id
        }

        if let compid = self.company?.id {
            rawData["company"] = compid
        }

        _ = APIManager.shared.makePOSTRequest(with: "user/detail", parameters: rawData) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    print("Update user profile error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    func updateDisclosureSettings(_ completion: @escaping (Bool) -> Void) {
        var rawSettings: [String: Any] = [:]
        for setting in self.disclosureSettings {
            rawSettings[setting.key.rawValue] = setting.value
        }

        _ = APIManager.shared.makePOSTRequest(with: "user/setting", parameters: rawSettings) { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    print("Update user settings error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}


