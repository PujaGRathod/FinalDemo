//
//  GetUserProfile.swift
//
//  Created by C025 on 25/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetUserProfile: NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let lastLogin = "last_login"
        static let photoPrivacy = "photo_privacy"
        static let phoneno = "phoneno"
        static let birthDate = "birth_date"
        static let platform = "platform"
        static let userId = "user_id"
        static let changeNumberCode = "change_number_code"
        static let groupNotification = "group_notification"
        static let lastSeenSetting = "last_seen_setting"
        static let bio = "bio"
        static let isVerify = "is_verify"
        static let statusPrivacy = "status_privacy"
        static let isDeleted = "is_deleted"
        static let image = "image"
        static let code = "code"
        static let creationDatetime = "creation_datetime"
        static let countryCode = "country_code"
        static let followers = "followers"
        static let isTwoStepVerification = "is_two_step_verification"
        static let following = "following"
        static let blockedContacts = "blocked_contacts"
        static let isFollowing = "is_following"
        static let pin = "pin"
        static let mutedByMe = "muted_by_me"
        static let email = "email"
        static let postData = "post_data"
        static let fullName = "full_name"
        static let address = "address"
        static let changeNumber = "change_number"
        static let postCount = "post_count"
        static let lastseenPrivacy = "lastseen_privacy"
        static let isOnline = "is_online"
        static let readReceiptsPrivacy = "read_receipts_privacy"
        static let gender = "gender"
        static let username = "username"
        static let statusSetting = "status_setting"
        static let status = "status"
        static let userPrivacy = "user_privacy"
        static let messageNotification = "message_notification"
        static let aboutPrivacy = "about_privacy"
        static let coverimage = "coverimage"
        static let userType = "user_type"
        static let modificationDatetime = "modification_datetime"
        static let profilePhotoSetting = "profile_photo_setting"
        static let imagePath = "image_path"
        static let deviceId = "device_id"
    }
    
    // MARK: Properties
    public var lastLogin: String?
    public var photoPrivacy: String?
    public var phoneno: String?
    public var birthDate: String?
    public var platform: String?
    public var userId: String?
    public var changeNumberCode: String?
    public var groupNotification: String?
    public var lastSeenSetting: String?
    public var bio: String?
    public var isVerify: String?
    public var statusPrivacy: String?
    public var isDeleted: String?
    public var image: String?
    public var code: String?
    public var creationDatetime: String?
    public var countryCode: String?
    public var followers: Int?
    public var isTwoStepVerification: String?
    public var following: Int?
    public var blockedContacts: String?
    public var isFollowing: Bool? = false
    public var pin: String?
    public var mutedByMe: String?
    public var email: String?
    public var postData: [PostData]?
    public var fullName: String?
    public var address: String?
    public var changeNumber: String?
    public var postCount: Int?
    public var lastseenPrivacy: String?
    public var isOnline: String?
    public var readReceiptsPrivacy: String?
    public var gender: String?
    public var username: String?
    public var statusSetting: String?
    public var status: String?
    public var userPrivacy: String?
    public var messageNotification: String?
    public var aboutPrivacy: String?
    public var coverimage: String?
    public var userType: String?
    public var modificationDatetime: String?
    public var profilePhotoSetting: String?
    public var imagePath: String?
    public var deviceId: String?
    
    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        lastLogin = json[SerializationKeys.lastLogin].string
        photoPrivacy = json[SerializationKeys.photoPrivacy].string
        phoneno = json[SerializationKeys.phoneno].string
        birthDate = json[SerializationKeys.birthDate].string
        platform = json[SerializationKeys.platform].string
        userId = json[SerializationKeys.userId].string
        changeNumberCode = json[SerializationKeys.changeNumberCode].string
        groupNotification = json[SerializationKeys.groupNotification].string
        lastSeenSetting = json[SerializationKeys.lastSeenSetting].string
        bio = json[SerializationKeys.bio].string
        isVerify = json[SerializationKeys.isVerify].string
        statusPrivacy = json[SerializationKeys.statusPrivacy].string
        isDeleted = json[SerializationKeys.isDeleted].string
        image = json[SerializationKeys.image].string
        code = json[SerializationKeys.code].string
        creationDatetime = json[SerializationKeys.creationDatetime].string
        countryCode = json[SerializationKeys.countryCode].string
        followers = json[SerializationKeys.followers].int
        isTwoStepVerification = json[SerializationKeys.isTwoStepVerification].string
        following = json[SerializationKeys.following].int
        blockedContacts = json[SerializationKeys.blockedContacts].string
        isFollowing = json[SerializationKeys.isFollowing].boolValue
        pin = json[SerializationKeys.pin].string
        mutedByMe = json[SerializationKeys.mutedByMe].string
        email = json[SerializationKeys.email].string
        if let items = json[SerializationKeys.postData].array { postData = items.map { PostData(json: $0) } }
        fullName = json[SerializationKeys.fullName].string
        address = json[SerializationKeys.address].string
        changeNumber = json[SerializationKeys.changeNumber].string
        postCount = json[SerializationKeys.postCount].int
        lastseenPrivacy = json[SerializationKeys.lastseenPrivacy].string
        isOnline = json[SerializationKeys.isOnline].string
        readReceiptsPrivacy = json[SerializationKeys.readReceiptsPrivacy].string
        gender = json[SerializationKeys.gender].string
        username = json[SerializationKeys.username].string
        statusSetting = json[SerializationKeys.statusSetting].string
        status = json[SerializationKeys.status].string
        userPrivacy = json[SerializationKeys.userPrivacy].string
        messageNotification = json[SerializationKeys.messageNotification].string
        aboutPrivacy = json[SerializationKeys.aboutPrivacy].string
        coverimage = json[SerializationKeys.coverimage].string
        userType = json[SerializationKeys.userType].string
        modificationDatetime = json[SerializationKeys.modificationDatetime].string
        profilePhotoSetting = json[SerializationKeys.profilePhotoSetting].string
        imagePath = json[SerializationKeys.imagePath].string
        deviceId = json[SerializationKeys.deviceId].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = lastLogin { dictionary[SerializationKeys.lastLogin] = value }
        if let value = photoPrivacy { dictionary[SerializationKeys.photoPrivacy] = value }
        if let value = phoneno { dictionary[SerializationKeys.phoneno] = value }
        if let value = birthDate { dictionary[SerializationKeys.birthDate] = value }
        if let value = platform { dictionary[SerializationKeys.platform] = value }
        if let value = userId { dictionary[SerializationKeys.userId] = value }
        if let value = changeNumberCode { dictionary[SerializationKeys.changeNumberCode] = value }
        if let value = groupNotification { dictionary[SerializationKeys.groupNotification] = value }
        if let value = lastSeenSetting { dictionary[SerializationKeys.lastSeenSetting] = value }
        if let value = bio { dictionary[SerializationKeys.bio] = value }
        if let value = isVerify { dictionary[SerializationKeys.isVerify] = value }
        if let value = statusPrivacy { dictionary[SerializationKeys.statusPrivacy] = value }
        if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
        if let value = image { dictionary[SerializationKeys.image] = value }
        if let value = code { dictionary[SerializationKeys.code] = value }
        if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
        if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
        if let value = followers { dictionary[SerializationKeys.followers] = value }
        if let value = isTwoStepVerification { dictionary[SerializationKeys.isTwoStepVerification] = value }
        if let value = following { dictionary[SerializationKeys.following] = value }
        if let value = blockedContacts { dictionary[SerializationKeys.blockedContacts] = value }
        dictionary[SerializationKeys.isFollowing] = isFollowing
        if let value = pin { dictionary[SerializationKeys.pin] = value }
        if let value = mutedByMe { dictionary[SerializationKeys.mutedByMe] = value }
        if let value = email { dictionary[SerializationKeys.email] = value }
        if let value = postData { dictionary[SerializationKeys.postData] = value.map { $0.dictionaryRepresentation() } }
        if let value = fullName { dictionary[SerializationKeys.fullName] = value }
        if let value = address { dictionary[SerializationKeys.address] = value }
        if let value = changeNumber { dictionary[SerializationKeys.changeNumber] = value }
        if let value = postCount { dictionary[SerializationKeys.postCount] = value }
        if let value = lastseenPrivacy { dictionary[SerializationKeys.lastseenPrivacy] = value }
        if let value = isOnline { dictionary[SerializationKeys.isOnline] = value }
        if let value = readReceiptsPrivacy { dictionary[SerializationKeys.readReceiptsPrivacy] = value }
        if let value = gender { dictionary[SerializationKeys.gender] = value }
        if let value = username { dictionary[SerializationKeys.username] = value }
        if let value = statusSetting { dictionary[SerializationKeys.statusSetting] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = userPrivacy { dictionary[SerializationKeys.userPrivacy] = value }
        if let value = messageNotification { dictionary[SerializationKeys.messageNotification] = value }
        if let value = aboutPrivacy { dictionary[SerializationKeys.aboutPrivacy] = value }
        if let value = coverimage { dictionary[SerializationKeys.coverimage] = value }
        if let value = userType { dictionary[SerializationKeys.userType] = value }
        if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
        if let value = profilePhotoSetting { dictionary[SerializationKeys.profilePhotoSetting] = value }
        if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
        if let value = deviceId { dictionary[SerializationKeys.deviceId] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.lastLogin = aDecoder.decodeObject(forKey: SerializationKeys.lastLogin) as? String
        self.photoPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.photoPrivacy) as? String
        self.phoneno = aDecoder.decodeObject(forKey: SerializationKeys.phoneno) as? String
        self.birthDate = aDecoder.decodeObject(forKey: SerializationKeys.birthDate) as? String
        self.platform = aDecoder.decodeObject(forKey: SerializationKeys.platform) as? String
        self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
        self.changeNumberCode = aDecoder.decodeObject(forKey: SerializationKeys.changeNumberCode) as? String
        self.groupNotification = aDecoder.decodeObject(forKey: SerializationKeys.groupNotification) as? String
        self.lastSeenSetting = aDecoder.decodeObject(forKey: SerializationKeys.lastSeenSetting) as? String
        self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
        self.isVerify = aDecoder.decodeObject(forKey: SerializationKeys.isVerify) as? String
        self.statusPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.statusPrivacy) as? String
        self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
        self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
        self.code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
        self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
        self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
        self.followers = aDecoder.decodeObject(forKey: SerializationKeys.followers) as? Int
        self.isTwoStepVerification = aDecoder.decodeObject(forKey: SerializationKeys.isTwoStepVerification) as? String
        self.following = aDecoder.decodeObject(forKey: SerializationKeys.following) as? Int
        self.blockedContacts = aDecoder.decodeObject(forKey: SerializationKeys.blockedContacts) as? String
        self.isFollowing = aDecoder.decodeBool(forKey: SerializationKeys.isFollowing)
        self.pin = aDecoder.decodeObject(forKey: SerializationKeys.pin) as? String
        self.mutedByMe = aDecoder.decodeObject(forKey: SerializationKeys.mutedByMe) as? String
        self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
        self.postData = aDecoder.decodeObject(forKey: SerializationKeys.postData) as? [PostData]
        self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
        self.address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
        self.changeNumber = aDecoder.decodeObject(forKey: SerializationKeys.changeNumber) as? String
        self.postCount = aDecoder.decodeObject(forKey: SerializationKeys.postCount) as? Int
        self.lastseenPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.lastseenPrivacy) as? String
        self.isOnline = aDecoder.decodeObject(forKey: SerializationKeys.isOnline) as? String
        self.readReceiptsPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.readReceiptsPrivacy) as? String
        self.gender = aDecoder.decodeObject(forKey: SerializationKeys.gender) as? String
        self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
        self.statusSetting = aDecoder.decodeObject(forKey: SerializationKeys.statusSetting) as? String
        self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
        self.userPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.userPrivacy) as? String
        self.messageNotification = aDecoder.decodeObject(forKey: SerializationKeys.messageNotification) as? String
        self.aboutPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.aboutPrivacy) as? String
        self.coverimage = aDecoder.decodeObject(forKey: SerializationKeys.coverimage) as? String
        self.userType = aDecoder.decodeObject(forKey: SerializationKeys.userType) as? String
        self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
        self.profilePhotoSetting = aDecoder.decodeObject(forKey: SerializationKeys.profilePhotoSetting) as? String
        self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
        self.deviceId = aDecoder.decodeObject(forKey: SerializationKeys.deviceId) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(lastLogin, forKey: SerializationKeys.lastLogin)
        aCoder.encode(photoPrivacy, forKey: SerializationKeys.photoPrivacy)
        aCoder.encode(phoneno, forKey: SerializationKeys.phoneno)
        aCoder.encode(birthDate, forKey: SerializationKeys.birthDate)
        aCoder.encode(platform, forKey: SerializationKeys.platform)
        aCoder.encode(userId, forKey: SerializationKeys.userId)
        aCoder.encode(changeNumberCode, forKey: SerializationKeys.changeNumberCode)
        aCoder.encode(groupNotification, forKey: SerializationKeys.groupNotification)
        aCoder.encode(lastSeenSetting, forKey: SerializationKeys.lastSeenSetting)
        aCoder.encode(bio, forKey: SerializationKeys.bio)
        aCoder.encode(isVerify, forKey: SerializationKeys.isVerify)
        aCoder.encode(statusPrivacy, forKey: SerializationKeys.statusPrivacy)
        aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
        aCoder.encode(image, forKey: SerializationKeys.image)
        aCoder.encode(code, forKey: SerializationKeys.code)
        aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
        aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
        aCoder.encode(followers, forKey: SerializationKeys.followers)
        aCoder.encode(isTwoStepVerification, forKey: SerializationKeys.isTwoStepVerification)
        aCoder.encode(following, forKey: SerializationKeys.following)
        aCoder.encode(blockedContacts, forKey: SerializationKeys.blockedContacts)
        aCoder.encode(isFollowing, forKey: SerializationKeys.isFollowing)
        aCoder.encode(pin, forKey: SerializationKeys.pin)
        aCoder.encode(mutedByMe, forKey: SerializationKeys.mutedByMe)
        aCoder.encode(email, forKey: SerializationKeys.email)
        aCoder.encode(postData, forKey: SerializationKeys.postData)
        aCoder.encode(fullName, forKey: SerializationKeys.fullName)
        aCoder.encode(address, forKey: SerializationKeys.address)
        aCoder.encode(changeNumber, forKey: SerializationKeys.changeNumber)
        aCoder.encode(postCount, forKey: SerializationKeys.postCount)
        aCoder.encode(lastseenPrivacy, forKey: SerializationKeys.lastseenPrivacy)
        aCoder.encode(isOnline, forKey: SerializationKeys.isOnline)
        aCoder.encode(readReceiptsPrivacy, forKey: SerializationKeys.readReceiptsPrivacy)
        aCoder.encode(gender, forKey: SerializationKeys.gender)
        aCoder.encode(username, forKey: SerializationKeys.username)
        aCoder.encode(statusSetting, forKey: SerializationKeys.statusSetting)
        aCoder.encode(status, forKey: SerializationKeys.status)
        aCoder.encode(userPrivacy, forKey: SerializationKeys.userPrivacy)
        aCoder.encode(messageNotification, forKey: SerializationKeys.messageNotification)
        aCoder.encode(aboutPrivacy, forKey: SerializationKeys.aboutPrivacy)
        aCoder.encode(coverimage, forKey: SerializationKeys.coverimage)
        aCoder.encode(userType, forKey: SerializationKeys.userType)
        aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
        aCoder.encode(profilePhotoSetting, forKey: SerializationKeys.profilePhotoSetting)
        aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
        aCoder.encode(deviceId, forKey: SerializationKeys.deviceId)
    }
    
}
