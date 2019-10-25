//
//  PostData.swift
//
//  Created by C025 on 25/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class PostData: NSObject, NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let lastLogin = "last_login"
        static let phoneno = "phoneno"
        static let peopleTags = "people_tags"
        static let platform = "platform"
        static let groupNotification = "group_notification"
        static let isVerify = "is_verify"
        static let bio = "bio"
        static let latitude = "latitude"
        static let likeCount = "like_count"
        static let statusPrivacy = "status_privacy"
        static let image = "image"
        static let creationDatetime = "creation_datetime"
        static let isTwoStepVerification = "is_two_step_verification"
        static let pin = "pin"
        static let mutedByMe = "muted_by_me"
        static let postType = "post_type"
        static let fullName = "full_name"
        static let address = "address"
        static let isLike = "is_like"
        static let username = "username"
        static let statusSetting = "status_setting"
        static let userPrivacy = "user_privacy"
        static let commentCount = "comment_count"
        static let postImages = "post_images"
        static let messageNotification = "message_notification"
        static let aboutPrivacy = "about_privacy"
        static let profilePhotoSetting = "profile_photo_setting"
        static let coverimage = "coverimage"
        static let photoPrivacy = "photo_privacy"
        static let birthDate = "birth_date"
        static let postDescIos = "postDescIos"
        static let lastSeenSetting = "last_seen_setting"
        static let postId = "post_id"
        static let code = "code"
        static let isDeleted = "is_deleted"
        static let countryCode = "country_code"
        static let blockedContacts = "blocked_contacts"
        static let longitude = "longitude"
        static let mapImage = "map_image"
        static let email = "email"
        static let changeNumber = "change_number"
        static let gender = "gender"
        static let lastseenPrivacy = "lastseen_privacy"
        static let isOnline = "is_online"
        static let readReceiptsPrivacy = "read_receipts_privacy"
        static let status = "status"
        static let location = "location"
        static let postDesc = "post_desc"
        static let userType = "user_type"
        static let userId = "user_id"
        static let deviceId = "device_id"
        static let modificationDatetime = "modification_datetime"
        static let changeNumberCode = "change_number_code"
    }
    
    // MARK: Properties
    public var lastLogin: String?
    public var phoneno: String?
    public var peopleTags: String?
    public var platform: String?
    public var groupNotification: String?
    public var isVerify: String?
    public var bio: String?
    public var latitude: String?
    public var likeCount: Int?
    public var statusPrivacy: String?
    public var image: String?
    public var creationDatetime: String?
    public var isTwoStepVerification: String?
    public var pin: String?
    public var mutedByMe: String?
    public var postType: String?
    public var fullName: String?
    public var address: String?
    public var isLike: Bool? = false
    public var username: String?
    public var statusSetting: String?
    public var userPrivacy: String?
    public var commentCount: Int?
    public var postImages: [PostImages]?
    public var messageNotification: String?
    public var aboutPrivacy: String?
    public var profilePhotoSetting: String?
    public var coverimage: String?
    public var photoPrivacy: String?
    public var birthDate: String?
    public var postDescIos: String?
    public var lastSeenSetting: String?
    public var postId: String?
    public var code: String?
    public var isDeleted: String?
    public var countryCode: String?
    public var blockedContacts: String?
    public var longitude: String?
    public var mapImage: String?
    public var email: String?
    public var changeNumber: String?
    public var gender: String?
    public var lastseenPrivacy: String?
    public var isOnline: String?
    public var readReceiptsPrivacy: String?
    public var status: String?
    public var location: String?
    public var postDesc: String?
    public var userType: String?
    public var userId: String?
    public var deviceId: String?
    public var modificationDatetime: String?
    public var changeNumberCode: String?
    
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
        phoneno = json[SerializationKeys.phoneno].string
        peopleTags = json[SerializationKeys.peopleTags].string
        platform = json[SerializationKeys.platform].string
        groupNotification = json[SerializationKeys.groupNotification].string
        isVerify = json[SerializationKeys.isVerify].string
        bio = json[SerializationKeys.bio].string
        latitude = json[SerializationKeys.latitude].string
        likeCount = json[SerializationKeys.likeCount].int
        statusPrivacy = json[SerializationKeys.statusPrivacy].string
        image = json[SerializationKeys.image].string
        creationDatetime = json[SerializationKeys.creationDatetime].string
        isTwoStepVerification = json[SerializationKeys.isTwoStepVerification].string
        pin = json[SerializationKeys.pin].string
        mutedByMe = json[SerializationKeys.mutedByMe].string
        postType = json[SerializationKeys.postType].string
        fullName = json[SerializationKeys.fullName].string
        address = json[SerializationKeys.address].string
        isLike = json[SerializationKeys.isLike].boolValue
        username = json[SerializationKeys.username].string
        statusSetting = json[SerializationKeys.statusSetting].string
        userPrivacy = json[SerializationKeys.userPrivacy].string
        commentCount = json[SerializationKeys.commentCount].int
        if let items = json[SerializationKeys.postImages].array { postImages = items.map { PostImages(json: $0) } }
        messageNotification = json[SerializationKeys.messageNotification].string
        aboutPrivacy = json[SerializationKeys.aboutPrivacy].string
        profilePhotoSetting = json[SerializationKeys.profilePhotoSetting].string
        coverimage = json[SerializationKeys.coverimage].string
        photoPrivacy = json[SerializationKeys.photoPrivacy].string
        birthDate = json[SerializationKeys.birthDate].string
        postDescIos = json[SerializationKeys.postDescIos].string
        lastSeenSetting = json[SerializationKeys.lastSeenSetting].string
        postId = json[SerializationKeys.postId].string
        code = json[SerializationKeys.code].string
        isDeleted = json[SerializationKeys.isDeleted].string
        countryCode = json[SerializationKeys.countryCode].string
        blockedContacts = json[SerializationKeys.blockedContacts].string
        longitude = json[SerializationKeys.longitude].string
        mapImage = json[SerializationKeys.mapImage].string
        email = json[SerializationKeys.email].string
        changeNumber = json[SerializationKeys.changeNumber].string
        gender = json[SerializationKeys.gender].string
        lastseenPrivacy = json[SerializationKeys.lastseenPrivacy].string
        isOnline = json[SerializationKeys.isOnline].string
        readReceiptsPrivacy = json[SerializationKeys.readReceiptsPrivacy].string
        status = json[SerializationKeys.status].string
        location = json[SerializationKeys.location].string
        postDesc = json[SerializationKeys.postDesc].string
        userType = json[SerializationKeys.userType].string
        userId = json[SerializationKeys.userId].string
        deviceId = json[SerializationKeys.deviceId].string
        modificationDatetime = json[SerializationKeys.modificationDatetime].string
        changeNumberCode = json[SerializationKeys.changeNumberCode].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = lastLogin { dictionary[SerializationKeys.lastLogin] = value }
        if let value = phoneno { dictionary[SerializationKeys.phoneno] = value }
        if let value = peopleTags { dictionary[SerializationKeys.peopleTags] = value }
        if let value = platform { dictionary[SerializationKeys.platform] = value }
        if let value = groupNotification { dictionary[SerializationKeys.groupNotification] = value }
        if let value = isVerify { dictionary[SerializationKeys.isVerify] = value }
        if let value = bio { dictionary[SerializationKeys.bio] = value }
        if let value = latitude { dictionary[SerializationKeys.latitude] = value }
        if let value = likeCount { dictionary[SerializationKeys.likeCount] = value }
        if let value = statusPrivacy { dictionary[SerializationKeys.statusPrivacy] = value }
        if let value = image { dictionary[SerializationKeys.image] = value }
        if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
        if let value = isTwoStepVerification { dictionary[SerializationKeys.isTwoStepVerification] = value }
        if let value = pin { dictionary[SerializationKeys.pin] = value }
        if let value = mutedByMe { dictionary[SerializationKeys.mutedByMe] = value }
        if let value = postType { dictionary[SerializationKeys.postType] = value }
        if let value = fullName { dictionary[SerializationKeys.fullName] = value }
        if let value = address { dictionary[SerializationKeys.address] = value }
        dictionary[SerializationKeys.isLike] = isLike
        if let value = username { dictionary[SerializationKeys.username] = value }
        if let value = statusSetting { dictionary[SerializationKeys.statusSetting] = value }
        if let value = userPrivacy { dictionary[SerializationKeys.userPrivacy] = value }
        if let value = commentCount { dictionary[SerializationKeys.commentCount] = value }
        if let value = postImages { dictionary[SerializationKeys.postImages] = value.map { $0.dictionaryRepresentation() } }
        if let value = messageNotification { dictionary[SerializationKeys.messageNotification] = value }
        if let value = aboutPrivacy { dictionary[SerializationKeys.aboutPrivacy] = value }
        if let value = profilePhotoSetting { dictionary[SerializationKeys.profilePhotoSetting] = value }
        if let value = coverimage { dictionary[SerializationKeys.coverimage] = value }
        if let value = photoPrivacy { dictionary[SerializationKeys.photoPrivacy] = value }
        if let value = birthDate { dictionary[SerializationKeys.birthDate] = value }
        if let value = postDescIos { dictionary[SerializationKeys.postDescIos] = value }
        if let value = lastSeenSetting { dictionary[SerializationKeys.lastSeenSetting] = value }
        if let value = postId { dictionary[SerializationKeys.postId] = value }
        if let value = code { dictionary[SerializationKeys.code] = value }
        if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
        if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
        if let value = blockedContacts { dictionary[SerializationKeys.blockedContacts] = value }
        if let value = longitude { dictionary[SerializationKeys.longitude] = value }
        if let value = mapImage { dictionary[SerializationKeys.mapImage] = value }
        if let value = email { dictionary[SerializationKeys.email] = value }
        if let value = changeNumber { dictionary[SerializationKeys.changeNumber] = value }
        if let value = gender { dictionary[SerializationKeys.gender] = value }
        if let value = lastseenPrivacy { dictionary[SerializationKeys.lastseenPrivacy] = value }
        if let value = isOnline { dictionary[SerializationKeys.isOnline] = value }
        if let value = readReceiptsPrivacy { dictionary[SerializationKeys.readReceiptsPrivacy] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = location { dictionary[SerializationKeys.location] = value }
        if let value = postDesc { dictionary[SerializationKeys.postDesc] = value }
        if let value = userType { dictionary[SerializationKeys.userType] = value }
        if let value = userId { dictionary[SerializationKeys.userId] = value }
        if let value = deviceId { dictionary[SerializationKeys.deviceId] = value }
        if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
        if let value = changeNumberCode { dictionary[SerializationKeys.changeNumberCode] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.lastLogin = aDecoder.decodeObject(forKey: SerializationKeys.lastLogin) as? String
        self.phoneno = aDecoder.decodeObject(forKey: SerializationKeys.phoneno) as? String
        self.peopleTags = aDecoder.decodeObject(forKey: SerializationKeys.peopleTags) as? String
        self.platform = aDecoder.decodeObject(forKey: SerializationKeys.platform) as? String
        self.groupNotification = aDecoder.decodeObject(forKey: SerializationKeys.groupNotification) as? String
        self.isVerify = aDecoder.decodeObject(forKey: SerializationKeys.isVerify) as? String
        self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
        self.latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
        self.likeCount = aDecoder.decodeObject(forKey: SerializationKeys.likeCount) as? Int
        self.statusPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.statusPrivacy) as? String
        self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
        self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
        self.isTwoStepVerification = aDecoder.decodeObject(forKey: SerializationKeys.isTwoStepVerification) as? String
        self.pin = aDecoder.decodeObject(forKey: SerializationKeys.pin) as? String
        self.mutedByMe = aDecoder.decodeObject(forKey: SerializationKeys.mutedByMe) as? String
        self.postType = aDecoder.decodeObject(forKey: SerializationKeys.postType) as? String
        self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
        self.address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
        self.isLike = aDecoder.decodeBool(forKey: SerializationKeys.isLike)
        self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
        self.statusSetting = aDecoder.decodeObject(forKey: SerializationKeys.statusSetting) as? String
        self.userPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.userPrivacy) as? String
        self.commentCount = aDecoder.decodeObject(forKey: SerializationKeys.commentCount) as? Int
        self.postImages = aDecoder.decodeObject(forKey: SerializationKeys.postImages) as? [PostImages]
        self.messageNotification = aDecoder.decodeObject(forKey: SerializationKeys.messageNotification) as? String
        self.aboutPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.aboutPrivacy) as? String
        self.profilePhotoSetting = aDecoder.decodeObject(forKey: SerializationKeys.profilePhotoSetting) as? String
        self.coverimage = aDecoder.decodeObject(forKey: SerializationKeys.coverimage) as? String
        self.photoPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.photoPrivacy) as? String
        self.birthDate = aDecoder.decodeObject(forKey: SerializationKeys.birthDate) as? String
        self.postDescIos = aDecoder.decodeObject(forKey: SerializationKeys.postDescIos) as? String
        self.lastSeenSetting = aDecoder.decodeObject(forKey: SerializationKeys.lastSeenSetting) as? String
        self.postId = aDecoder.decodeObject(forKey: SerializationKeys.postId) as? String
        self.code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
        self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
        self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
        self.blockedContacts = aDecoder.decodeObject(forKey: SerializationKeys.blockedContacts) as? String
        self.longitude = aDecoder.decodeObject(forKey: SerializationKeys.longitude) as? String
        self.mapImage = aDecoder.decodeObject(forKey: SerializationKeys.mapImage) as? String
        self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
        self.changeNumber = aDecoder.decodeObject(forKey: SerializationKeys.changeNumber) as? String
        self.gender = aDecoder.decodeObject(forKey: SerializationKeys.gender) as? String
        self.lastseenPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.lastseenPrivacy) as? String
        self.isOnline = aDecoder.decodeObject(forKey: SerializationKeys.isOnline) as? String
        self.readReceiptsPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.readReceiptsPrivacy) as? String
        self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
        self.location = aDecoder.decodeObject(forKey: SerializationKeys.location) as? String
        self.postDesc = aDecoder.decodeObject(forKey: SerializationKeys.postDesc) as? String
        self.userType = aDecoder.decodeObject(forKey: SerializationKeys.userType) as? String
        self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
        self.deviceId = aDecoder.decodeObject(forKey: SerializationKeys.deviceId) as? String
        self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
        self.changeNumberCode = aDecoder.decodeObject(forKey: SerializationKeys.changeNumberCode) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(lastLogin, forKey: SerializationKeys.lastLogin)
        aCoder.encode(phoneno, forKey: SerializationKeys.phoneno)
        aCoder.encode(peopleTags, forKey: SerializationKeys.peopleTags)
        aCoder.encode(platform, forKey: SerializationKeys.platform)
        aCoder.encode(groupNotification, forKey: SerializationKeys.groupNotification)
        aCoder.encode(isVerify, forKey: SerializationKeys.isVerify)
        aCoder.encode(bio, forKey: SerializationKeys.bio)
        aCoder.encode(latitude, forKey: SerializationKeys.latitude)
        aCoder.encode(likeCount, forKey: SerializationKeys.likeCount)
        aCoder.encode(statusPrivacy, forKey: SerializationKeys.statusPrivacy)
        aCoder.encode(image, forKey: SerializationKeys.image)
        aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
        aCoder.encode(isTwoStepVerification, forKey: SerializationKeys.isTwoStepVerification)
        aCoder.encode(pin, forKey: SerializationKeys.pin)
        aCoder.encode(mutedByMe, forKey: SerializationKeys.mutedByMe)
        aCoder.encode(postType, forKey: SerializationKeys.postType)
        aCoder.encode(fullName, forKey: SerializationKeys.fullName)
        aCoder.encode(address, forKey: SerializationKeys.address)
        aCoder.encode(isLike, forKey: SerializationKeys.isLike)
        aCoder.encode(username, forKey: SerializationKeys.username)
        aCoder.encode(statusSetting, forKey: SerializationKeys.statusSetting)
        aCoder.encode(userPrivacy, forKey: SerializationKeys.userPrivacy)
        aCoder.encode(commentCount, forKey: SerializationKeys.commentCount)
        aCoder.encode(postImages, forKey: SerializationKeys.postImages)
        aCoder.encode(messageNotification, forKey: SerializationKeys.messageNotification)
        aCoder.encode(aboutPrivacy, forKey: SerializationKeys.aboutPrivacy)
        aCoder.encode(profilePhotoSetting, forKey: SerializationKeys.profilePhotoSetting)
        aCoder.encode(coverimage, forKey: SerializationKeys.coverimage)
        aCoder.encode(photoPrivacy, forKey: SerializationKeys.photoPrivacy)
        aCoder.encode(birthDate, forKey: SerializationKeys.birthDate)
        aCoder.encode(postDescIos, forKey: SerializationKeys.postDescIos)
        aCoder.encode(lastSeenSetting, forKey: SerializationKeys.lastSeenSetting)
        aCoder.encode(postId, forKey: SerializationKeys.postId)
        aCoder.encode(code, forKey: SerializationKeys.code)
        aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
        aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
        aCoder.encode(blockedContacts, forKey: SerializationKeys.blockedContacts)
        aCoder.encode(longitude, forKey: SerializationKeys.longitude)
        aCoder.encode(mapImage, forKey: SerializationKeys.mapImage)
        aCoder.encode(email, forKey: SerializationKeys.email)
        aCoder.encode(changeNumber, forKey: SerializationKeys.changeNumber)
        aCoder.encode(gender, forKey: SerializationKeys.gender)
        aCoder.encode(lastseenPrivacy, forKey: SerializationKeys.lastseenPrivacy)
        aCoder.encode(isOnline, forKey: SerializationKeys.isOnline)
        aCoder.encode(readReceiptsPrivacy, forKey: SerializationKeys.readReceiptsPrivacy)
        aCoder.encode(status, forKey: SerializationKeys.status)
        aCoder.encode(location, forKey: SerializationKeys.location)
        aCoder.encode(postDesc, forKey: SerializationKeys.postDesc)
        aCoder.encode(userType, forKey: SerializationKeys.userType)
        aCoder.encode(userId, forKey: SerializationKeys.userId)
        aCoder.encode(deviceId, forKey: SerializationKeys.deviceId)
        aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
        aCoder.encode(changeNumberCode, forKey: SerializationKeys.changeNumberCode)
    }
    
}

