
//
//  SearchingContact.swift
//
//  Created by C025 on 21/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Searching_Contact: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let bio = "bio"
    static let phoneno = "phoneno"
    static let countryCode = "country_code"
    static let image = "image"
    static let isFollowing = "is_following"
    static let fullName = "full_name"
    static let userId = "user_id"
    static let username = "username"
    static let imagePath = "image_path"
  }

  // MARK: Properties
  public var bio: String?
  public var phoneno: String?
  public var countryCode: String?
  public var image: String?
  public var isFollowing: Bool? = false
  public var fullName: String?
  public var userId: String?
  public var username: String?
  public var imagePath: String?

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
    bio = json[SerializationKeys.bio].string
    phoneno = json[SerializationKeys.phoneno].string
    countryCode = json[SerializationKeys.countryCode].string
    image = json[SerializationKeys.image].string
    isFollowing = json[SerializationKeys.isFollowing].boolValue
    fullName = json[SerializationKeys.fullName].string
    userId = json[SerializationKeys.userId].string
    username = json[SerializationKeys.username].string
    imagePath = json[SerializationKeys.imagePath].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = bio { dictionary[SerializationKeys.bio] = value }
    if let value = phoneno { dictionary[SerializationKeys.phoneno] = value }
    if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
    if let value = image { dictionary[SerializationKeys.image] = value }
    dictionary[SerializationKeys.isFollowing] = isFollowing
    if let value = fullName { dictionary[SerializationKeys.fullName] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = username { dictionary[SerializationKeys.username] = value }
    if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
    self.phoneno = aDecoder.decodeObject(forKey: SerializationKeys.phoneno) as? String
    self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
    self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
    self.isFollowing = aDecoder.decodeBool(forKey: SerializationKeys.isFollowing)
    self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
    self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(bio, forKey: SerializationKeys.bio)
    aCoder.encode(phoneno, forKey: SerializationKeys.phoneno)
    aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
    aCoder.encode(image, forKey: SerializationKeys.image)
    aCoder.encode(isFollowing, forKey: SerializationKeys.isFollowing)
    aCoder.encode(fullName, forKey: SerializationKeys.fullName)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(username, forKey: SerializationKeys.username)
    aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
  }

}
