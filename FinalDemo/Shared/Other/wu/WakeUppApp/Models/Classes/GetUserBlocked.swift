//
//  GetUserBlocked.swift
//
//  Created by C025 on 20/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetUserBlocked: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let image = "image"
    static let userId = "user_id"
    static let fullName = "full_name"
    static let imagePath = "image_path"
    static let username = "username"
  }

  // MARK: Properties
  public var image: String?
  public var userId: String?
  public var fullName: String?
  public var imagePath: String?
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
    image = json[SerializationKeys.image].string
    userId = json[SerializationKeys.userId].string
    fullName = json[SerializationKeys.fullName].string
    imagePath = json[SerializationKeys.imagePath].string
    username = json[SerializationKeys.username].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = image { dictionary[SerializationKeys.image] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = fullName { dictionary[SerializationKeys.fullName] = value }
    if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
    if let value = username { dictionary[SerializationKeys.username] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
    self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(image, forKey: SerializationKeys.image)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(fullName, forKey: SerializationKeys.fullName)
    aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
    aCoder.encode(username, forKey: SerializationKeys.username)
  }

}
