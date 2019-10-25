//
//  SocketMessage.swift
//
//  Created by Admin on 28/03/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class SocketMessage: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let toid = "toid"
    static let name = "name"
    static let requestId = "request_id"
    static let userId = "user_id"
    static let msg = "msg"
    static let receiverId = "receiver_id"
  }

  // MARK: Properties
  public var toid: String?
  public var name: String?
  public var requestId: String?
  public var userId: String?
  public var msg: String?
  public var receiverId: String?

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
    toid = json[SerializationKeys.toid].string
    name = json[SerializationKeys.name].string
    requestId = json[SerializationKeys.requestId].string
    userId = json[SerializationKeys.userId].string
    msg = json[SerializationKeys.msg].string
    receiverId = json[SerializationKeys.receiverId].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = toid { dictionary[SerializationKeys.toid] = value }
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = requestId { dictionary[SerializationKeys.requestId] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = msg { dictionary[SerializationKeys.msg] = value }
    if let value = receiverId { dictionary[SerializationKeys.receiverId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.toid = aDecoder.decodeObject(forKey: SerializationKeys.toid) as? String
    self.name = aDecoder.decodeObject(forKey: SerializationKeys.name) as? String
    self.requestId = aDecoder.decodeObject(forKey: SerializationKeys.requestId) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.msg = aDecoder.decodeObject(forKey: SerializationKeys.msg) as? String
    self.receiverId = aDecoder.decodeObject(forKey: SerializationKeys.receiverId) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(toid, forKey: SerializationKeys.toid)
    aCoder.encode(name, forKey: SerializationKeys.name)
    aCoder.encode(requestId, forKey: SerializationKeys.requestId)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(msg, forKey: SerializationKeys.msg)
    aCoder.encode(receiverId, forKey: SerializationKeys.receiverId)
  }

}
