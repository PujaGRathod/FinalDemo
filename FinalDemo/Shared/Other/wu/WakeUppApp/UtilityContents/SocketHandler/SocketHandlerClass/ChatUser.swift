//
//  ChatUser.swift
//
//  Created by Admin on 28/03/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class ChatUser: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let userName = "userName"
    static let senderId = "sender_id"
    static let userId = "user_id"
    static let id = "id"
    static let isOnline = "is_online"
    static let receiverId = "receiver_id"
  }

  // MARK: Properties
  public var userName: String?
  public var senderId: Int?
  public var userId: Int?
  public var id: String?
  public var isOnline: Int?
  public var receiverId: Int?

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
    userName = json[SerializationKeys.userName].string
    senderId = json[SerializationKeys.senderId].int
    userId = json[SerializationKeys.userId].int
    id = json[SerializationKeys.id].string
    isOnline = json[SerializationKeys.isOnline].int
    receiverId = json[SerializationKeys.receiverId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = userName { dictionary[SerializationKeys.userName] = value }
    if let value = senderId { dictionary[SerializationKeys.senderId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = isOnline { dictionary[SerializationKeys.isOnline] = value }
    if let value = receiverId { dictionary[SerializationKeys.receiverId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.userName = aDecoder.decodeObject(forKey: SerializationKeys.userName) as? String
    self.senderId = aDecoder.decodeObject(forKey: SerializationKeys.senderId) as? Int
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? Int
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.isOnline = aDecoder.decodeObject(forKey: SerializationKeys.isOnline) as? Int
    self.receiverId = aDecoder.decodeObject(forKey: SerializationKeys.receiverId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(userName, forKey: SerializationKeys.userName)
    aCoder.encode(senderId, forKey: SerializationKeys.senderId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(isOnline, forKey: SerializationKeys.isOnline)
    aCoder.encode(receiverId, forKey: SerializationKeys.receiverId)
  }

}
