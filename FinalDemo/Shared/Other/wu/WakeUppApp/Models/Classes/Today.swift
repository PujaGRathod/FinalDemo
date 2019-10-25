//
//  Today.swift
//
//  Created by C025 on 14/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Today: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let profileImg = "profile_img"
    static let type = "type"
    static let notiType = "noti_type"
    static let id = "id"
    static let postId = "post_id"
    static let text = "text"
    static let isDeleted = "is_deleted"
    static let isView = "is_view"
    static let creationDatetime = "creation_datetime"
    static let userId = "user_id"
    static let modificationDatetime = "modification_datetime"
    static let postUserId = "post_user_id"
  }

  // MARK: Properties
  public var profileImg: String?
  public var type: String?
  public var notiType: String?
  public var id: String?
  public var postId: String?
  public var text: String?
  public var isDeleted: String?
  public var isView: String?
  public var creationDatetime: String?
  public var userId: String?
  public var modificationDatetime: String?
  public var postUserId: String?

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
    profileImg = json[SerializationKeys.profileImg].string
    type = json[SerializationKeys.type].string
    notiType = json[SerializationKeys.notiType].string
    id = json[SerializationKeys.id].string
    postId = json[SerializationKeys.postId].string
    text = json[SerializationKeys.text].string
    isDeleted = json[SerializationKeys.isDeleted].string
    isView = json[SerializationKeys.isView].string
    creationDatetime = json[SerializationKeys.creationDatetime].string
    userId = json[SerializationKeys.userId].string
    modificationDatetime = json[SerializationKeys.modificationDatetime].string
    postUserId = json[SerializationKeys.postUserId].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = profileImg { dictionary[SerializationKeys.profileImg] = value }
    if let value = type { dictionary[SerializationKeys.type] = value }
    if let value = notiType { dictionary[SerializationKeys.notiType] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = postId { dictionary[SerializationKeys.postId] = value }
    if let value = text { dictionary[SerializationKeys.text] = value }
    if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
    if let value = isView { dictionary[SerializationKeys.isView] = value }
    if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
    if let value = postUserId { dictionary[SerializationKeys.postUserId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.profileImg = aDecoder.decodeObject(forKey: SerializationKeys.profileImg) as? String
    self.type = aDecoder.decodeObject(forKey: SerializationKeys.type) as? String
    self.notiType = aDecoder.decodeObject(forKey: SerializationKeys.notiType) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
    self.postId = aDecoder.decodeObject(forKey: SerializationKeys.postId) as? String
    self.text = aDecoder.decodeObject(forKey: SerializationKeys.text) as? String
    self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
    self.isView = aDecoder.decodeObject(forKey: SerializationKeys.isView) as? String
    self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
    self.postUserId = aDecoder.decodeObject(forKey: SerializationKeys.postUserId) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(profileImg, forKey: SerializationKeys.profileImg)
    aCoder.encode(type, forKey: SerializationKeys.type)
    aCoder.encode(notiType, forKey: SerializationKeys.notiType)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(postId, forKey: SerializationKeys.postId)
    aCoder.encode(text, forKey: SerializationKeys.text)
    aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
    aCoder.encode(isView, forKey: SerializationKeys.isView)
    aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
    aCoder.encode(postUserId, forKey: SerializationKeys.postUserId)
  }

}
