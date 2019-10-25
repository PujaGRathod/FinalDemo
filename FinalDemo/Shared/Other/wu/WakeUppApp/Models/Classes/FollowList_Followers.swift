//
//  FollowListFollowers.swift
//
//  Created by C025 on 08/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class FollowList_Followers: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let lastLogin = "last_login"
    static let phoneno = "phoneno"
    static let birthDate = "birth_date"
    static let platform = "platform"
    static let lastSeenSetting = "last_seen_setting"
    static let bio = "bio"
    static let isVerify = "is_verify"
    static let followTo = "follow_to"
    static let isDeleted = "is_deleted"
    static let image = "image"
    static let code = "code"
    static let creationDatetime = "creation_datetime"
    static let countryCode = "country_code"
    static let isFollowing = "is_following"
    static let isTwoStepVerification = "is_two_step_verification"
    static let blockedContacts = "blocked_contacts"
    static let pin = "pin"
    static let mutedByMe = "muted_by_me"
    static let email = "email"
    static let fullName = "full_name"
    static let profileImg = "profile_img"
    static let address = "address"
    static let gender = "gender"
    static let followBy = "follow_by"
    static let isOnline = "is_online"
    static let lastseenPrivacy = "lastseen_privacy"
    static let followId = "follow_id"
    static let username = "username"
    static let statusSetting = "status_setting"
    static let status = "status"
    static let userPrivacy = "user_privacy"
    static let aboutPrivacy = "about_privacy"
    static let userType = "user_type"
    static let profilePhotoSetting = "profile_photo_setting"
    static let deviceId = "device_id"
    static let userId = "user_id"
    static let photoPrivacy = "photo_privacy"
    static let modificationDatetime = "modification_datetime"
  }

  // MARK: Properties
  public var lastLogin: String?
  public var phoneno: String?
  public var birthDate: String?
  public var platform: String?
  public var lastSeenSetting: String?
  public var bio: String?
  public var isVerify: String?
  public var followTo: String?
  public var isDeleted: String?
  public var image: String?
  public var code: String?
  public var creationDatetime: String?
  public var countryCode: String?
  public var isFollowing: Bool? = false
  public var isTwoStepVerification: String?
  public var blockedContacts: String?
  public var pin: String?
  public var mutedByMe: String?
  public var email: String?
  public var fullName: String?
  public var profileImg: String?
  public var address: String?
  public var gender: String?
  public var followBy: String?
  public var isOnline: String?
  public var lastseenPrivacy: String?
  public var followId: String?
  public var username: String?
  public var statusSetting: String?
  public var status: String?
  public var userPrivacy: String?
  public var aboutPrivacy: String?
  public var userType: String?
  public var profilePhotoSetting: String?
  public var deviceId: String?
  public var userId: String?
  public var photoPrivacy: String?
  public var modificationDatetime: String?

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
    birthDate = json[SerializationKeys.birthDate].string
    platform = json[SerializationKeys.platform].string
    lastSeenSetting = json[SerializationKeys.lastSeenSetting].string
    bio = json[SerializationKeys.bio].string
    isVerify = json[SerializationKeys.isVerify].string
    followTo = json[SerializationKeys.followTo].string
    isDeleted = json[SerializationKeys.isDeleted].string
    image = json[SerializationKeys.image].string
    code = json[SerializationKeys.code].string
    creationDatetime = json[SerializationKeys.creationDatetime].string
    countryCode = json[SerializationKeys.countryCode].string
    isFollowing = json[SerializationKeys.isFollowing].boolValue
    isTwoStepVerification = json[SerializationKeys.isTwoStepVerification].string
    blockedContacts = json[SerializationKeys.blockedContacts].string
    pin = json[SerializationKeys.pin].string
    mutedByMe = json[SerializationKeys.mutedByMe].string
    email = json[SerializationKeys.email].string
    fullName = json[SerializationKeys.fullName].string
    profileImg = json[SerializationKeys.profileImg].string
    address = json[SerializationKeys.address].string
    gender = json[SerializationKeys.gender].string
    followBy = json[SerializationKeys.followBy].string
    isOnline = json[SerializationKeys.isOnline].string
    lastseenPrivacy = json[SerializationKeys.lastseenPrivacy].string
    followId = json[SerializationKeys.followId].string
    username = json[SerializationKeys.username].string
    statusSetting = json[SerializationKeys.statusSetting].string
    status = json[SerializationKeys.status].string
    userPrivacy = json[SerializationKeys.userPrivacy].string
    aboutPrivacy = json[SerializationKeys.aboutPrivacy].string
    userType = json[SerializationKeys.userType].string
    profilePhotoSetting = json[SerializationKeys.profilePhotoSetting].string
    deviceId = json[SerializationKeys.deviceId].string
    userId = json[SerializationKeys.userId].string
    photoPrivacy = json[SerializationKeys.photoPrivacy].string
    modificationDatetime = json[SerializationKeys.modificationDatetime].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = lastLogin { dictionary[SerializationKeys.lastLogin] = value }
    if let value = phoneno { dictionary[SerializationKeys.phoneno] = value }
    if let value = birthDate { dictionary[SerializationKeys.birthDate] = value }
    if let value = platform { dictionary[SerializationKeys.platform] = value }
    if let value = lastSeenSetting { dictionary[SerializationKeys.lastSeenSetting] = value }
    if let value = bio { dictionary[SerializationKeys.bio] = value }
    if let value = isVerify { dictionary[SerializationKeys.isVerify] = value }
    if let value = followTo { dictionary[SerializationKeys.followTo] = value }
    if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
    if let value = image { dictionary[SerializationKeys.image] = value }
    if let value = code { dictionary[SerializationKeys.code] = value }
    if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
    if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
    dictionary[SerializationKeys.isFollowing] = isFollowing
    if let value = isTwoStepVerification { dictionary[SerializationKeys.isTwoStepVerification] = value }
    if let value = blockedContacts { dictionary[SerializationKeys.blockedContacts] = value }
    if let value = pin { dictionary[SerializationKeys.pin] = value }
    if let value = mutedByMe { dictionary[SerializationKeys.mutedByMe] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    if let value = fullName { dictionary[SerializationKeys.fullName] = value }
    if let value = profileImg { dictionary[SerializationKeys.profileImg] = value }
    if let value = address { dictionary[SerializationKeys.address] = value }
    if let value = gender { dictionary[SerializationKeys.gender] = value }
    if let value = followBy { dictionary[SerializationKeys.followBy] = value }
    if let value = isOnline { dictionary[SerializationKeys.isOnline] = value }
    if let value = lastseenPrivacy { dictionary[SerializationKeys.lastseenPrivacy] = value }
    if let value = followId { dictionary[SerializationKeys.followId] = value }
    if let value = username { dictionary[SerializationKeys.username] = value }
    if let value = statusSetting { dictionary[SerializationKeys.statusSetting] = value }
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = userPrivacy { dictionary[SerializationKeys.userPrivacy] = value }
    if let value = aboutPrivacy { dictionary[SerializationKeys.aboutPrivacy] = value }
    if let value = userType { dictionary[SerializationKeys.userType] = value }
    if let value = profilePhotoSetting { dictionary[SerializationKeys.profilePhotoSetting] = value }
    if let value = deviceId { dictionary[SerializationKeys.deviceId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = photoPrivacy { dictionary[SerializationKeys.photoPrivacy] = value }
    if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.lastLogin = aDecoder.decodeObject(forKey: SerializationKeys.lastLogin) as? String
    self.phoneno = aDecoder.decodeObject(forKey: SerializationKeys.phoneno) as? String
    self.birthDate = aDecoder.decodeObject(forKey: SerializationKeys.birthDate) as? String
    self.platform = aDecoder.decodeObject(forKey: SerializationKeys.platform) as? String
    self.lastSeenSetting = aDecoder.decodeObject(forKey: SerializationKeys.lastSeenSetting) as? String
    self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
    self.isVerify = aDecoder.decodeObject(forKey: SerializationKeys.isVerify) as? String
    self.followTo = aDecoder.decodeObject(forKey: SerializationKeys.followTo) as? String
    self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
    self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
    self.code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
    self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
    self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
    self.isFollowing = aDecoder.decodeBool(forKey: SerializationKeys.isFollowing)
    self.isTwoStepVerification = aDecoder.decodeObject(forKey: SerializationKeys.isTwoStepVerification) as? String
    self.blockedContacts = aDecoder.decodeObject(forKey: SerializationKeys.blockedContacts) as? String
    self.pin = aDecoder.decodeObject(forKey: SerializationKeys.pin) as? String
    self.mutedByMe = aDecoder.decodeObject(forKey: SerializationKeys.mutedByMe) as? String
    self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
    self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
    self.profileImg = aDecoder.decodeObject(forKey: SerializationKeys.profileImg) as? String
    self.address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
    self.gender = aDecoder.decodeObject(forKey: SerializationKeys.gender) as? String
    self.followBy = aDecoder.decodeObject(forKey: SerializationKeys.followBy) as? String
    self.isOnline = aDecoder.decodeObject(forKey: SerializationKeys.isOnline) as? String
    self.lastseenPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.lastseenPrivacy) as? String
    self.followId = aDecoder.decodeObject(forKey: SerializationKeys.followId) as? String
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
    self.statusSetting = aDecoder.decodeObject(forKey: SerializationKeys.statusSetting) as? String
    self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
    self.userPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.userPrivacy) as? String
    self.aboutPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.aboutPrivacy) as? String
    self.userType = aDecoder.decodeObject(forKey: SerializationKeys.userType) as? String
    self.profilePhotoSetting = aDecoder.decodeObject(forKey: SerializationKeys.profilePhotoSetting) as? String
    self.deviceId = aDecoder.decodeObject(forKey: SerializationKeys.deviceId) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.photoPrivacy = aDecoder.decodeObject(forKey: SerializationKeys.photoPrivacy) as? String
    self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(lastLogin, forKey: SerializationKeys.lastLogin)
    aCoder.encode(phoneno, forKey: SerializationKeys.phoneno)
    aCoder.encode(birthDate, forKey: SerializationKeys.birthDate)
    aCoder.encode(platform, forKey: SerializationKeys.platform)
    aCoder.encode(lastSeenSetting, forKey: SerializationKeys.lastSeenSetting)
    aCoder.encode(bio, forKey: SerializationKeys.bio)
    aCoder.encode(isVerify, forKey: SerializationKeys.isVerify)
    aCoder.encode(followTo, forKey: SerializationKeys.followTo)
    aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
    aCoder.encode(image, forKey: SerializationKeys.image)
    aCoder.encode(code, forKey: SerializationKeys.code)
    aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
    aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
    aCoder.encode(isFollowing, forKey: SerializationKeys.isFollowing)
    aCoder.encode(isTwoStepVerification, forKey: SerializationKeys.isTwoStepVerification)
    aCoder.encode(blockedContacts, forKey: SerializationKeys.blockedContacts)
    aCoder.encode(pin, forKey: SerializationKeys.pin)
    aCoder.encode(mutedByMe, forKey: SerializationKeys.mutedByMe)
    aCoder.encode(email, forKey: SerializationKeys.email)
    aCoder.encode(fullName, forKey: SerializationKeys.fullName)
    aCoder.encode(profileImg, forKey: SerializationKeys.profileImg)
    aCoder.encode(address, forKey: SerializationKeys.address)
    aCoder.encode(gender, forKey: SerializationKeys.gender)
    aCoder.encode(followBy, forKey: SerializationKeys.followBy)
    aCoder.encode(isOnline, forKey: SerializationKeys.isOnline)
    aCoder.encode(lastseenPrivacy, forKey: SerializationKeys.lastseenPrivacy)
    aCoder.encode(followId, forKey: SerializationKeys.followId)
    aCoder.encode(username, forKey: SerializationKeys.username)
    aCoder.encode(statusSetting, forKey: SerializationKeys.statusSetting)
    aCoder.encode(status, forKey: SerializationKeys.status)
    aCoder.encode(userPrivacy, forKey: SerializationKeys.userPrivacy)
    aCoder.encode(aboutPrivacy, forKey: SerializationKeys.aboutPrivacy)
    aCoder.encode(userType, forKey: SerializationKeys.userType)
    aCoder.encode(profilePhotoSetting, forKey: SerializationKeys.profilePhotoSetting)
    aCoder.encode(deviceId, forKey: SerializationKeys.deviceId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(photoPrivacy, forKey: SerializationKeys.photoPrivacy)
    aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
  }

}
