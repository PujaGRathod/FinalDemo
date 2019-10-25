//
//  GetSingleChannelDetails.swift
//
//  Created by C025 on 02/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetSingleChannelDetails: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let coverImg = "cover_img"
    static let subscribeCount = "subscribe_count"
    static let id = "id"
    static let descriptionValue = "description"
    static let createdUserid = "created_userid"
    static let logo = "logo"
    static let title = "title"
    static let videoCount = "video_count"
    static let userId = "user_id"
    static let isSubscribe = "is_subscribe"
    static let username = "username"
  }

  // MARK: Properties
  public var coverImg: String?
  public var subscribeCount: String?
  public var id: String?
  public var descriptionValue: String?
  public var createdUserid: Int?
  public var logo: String?
  public var title: String?
  public var videoCount: String?
  public var userId: String?
  public var isSubscribe: Bool? = false
  public var username: String?

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
    coverImg = json[SerializationKeys.coverImg].string
    subscribeCount = json[SerializationKeys.subscribeCount].string
    id = json[SerializationKeys.id].string
    descriptionValue = json[SerializationKeys.descriptionValue].string
    createdUserid = json[SerializationKeys.createdUserid].int
    logo = json[SerializationKeys.logo].string
    title = json[SerializationKeys.title].string
    videoCount = json[SerializationKeys.videoCount].string
    userId = json[SerializationKeys.userId].string
    isSubscribe = json[SerializationKeys.isSubscribe].boolValue
    username = json[SerializationKeys.username].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = coverImg { dictionary[SerializationKeys.coverImg] = value }
    if let value = subscribeCount { dictionary[SerializationKeys.subscribeCount] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = descriptionValue { dictionary[SerializationKeys.descriptionValue] = value }
    if let value = createdUserid { dictionary[SerializationKeys.createdUserid] = value }
    if let value = logo { dictionary[SerializationKeys.logo] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    if let value = videoCount { dictionary[SerializationKeys.videoCount] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    dictionary[SerializationKeys.isSubscribe] = isSubscribe
    if let value = username { dictionary[SerializationKeys.username] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.coverImg = aDecoder.decodeObject(forKey: SerializationKeys.coverImg) as? String
    self.subscribeCount = aDecoder.decodeObject(forKey: SerializationKeys.subscribeCount) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.descriptionValue = aDecoder.decodeObject(forKey: SerializationKeys.descriptionValue) as? String
    self.createdUserid = aDecoder.decodeObject(forKey: SerializationKeys.createdUserid) as? Int
    self.logo = aDecoder.decodeObject(forKey: SerializationKeys.logo) as? String
    self.title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
    self.videoCount = aDecoder.decodeObject(forKey: SerializationKeys.videoCount) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.isSubscribe = aDecoder.decodeBool(forKey: SerializationKeys.isSubscribe)
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(coverImg, forKey: SerializationKeys.coverImg)
    aCoder.encode(subscribeCount, forKey: SerializationKeys.subscribeCount)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(descriptionValue, forKey: SerializationKeys.descriptionValue)
    aCoder.encode(createdUserid, forKey: SerializationKeys.createdUserid)
    aCoder.encode(logo, forKey: SerializationKeys.logo)
    aCoder.encode(title, forKey: SerializationKeys.title)
    aCoder.encode(videoCount, forKey: SerializationKeys.videoCount)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(isSubscribe, forKey: SerializationKeys.isSubscribe)
    aCoder.encode(username, forKey: SerializationKeys.username)
  }

}
