//
//  Feeds.swift
//
//  Created by Admin on 13/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Feeds: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let mapImage = "map_image"
    static let peopleTags = "people_tags"
    static let fullName = "full_name"
    static let postType = "post_type"
    static let isLike = "is_like"
    static let username = "username"
    static let likeCount = "like_count"
    static let latitude = "latitude"
    static let location = "location"
    static let postDesc = "post_desc"
    static let postId = "post_id"
    static let image = "image"
    static let postImages = "post_images"
    static let postDescIos = "post_desc_ios"
    static let creationDatetime = "creation_datetime"
    static let commentCount = "comment_count"
    static let isDeleted = "is_deleted"
    static let userId = "user_id"
    static let modificationDatetime = "modification_datetime"
    static let longitude = "longitude"
    static let imagePath = "image_path"
  }

  // MARK: Properties
  public var mapImage: String?
  public var peopleTags: [PeopleTags]?
  public var fullName: String?
  public var postType: String?
  public var isLike: Bool? = false
  public var username: String?
  public var likeCount: Int?
  public var latitude: String?
  public var location: String?
  public var postDesc: String?
  public var postId: String?
  public var image: String?
  public var postImages: [PostImages]?
  public var postDescIos: String?
  public var creationDatetime: String?
  public var commentCount: Int?
  public var isDeleted: String?
  public var userId: String?
  public var modificationDatetime: String?
  public var longitude: String?
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
    mapImage = json[SerializationKeys.mapImage].string
    if let items = json[SerializationKeys.peopleTags].array { peopleTags = items.map { PeopleTags(json: $0) } }
    fullName = json[SerializationKeys.fullName].string
    postType = json[SerializationKeys.postType].string
    isLike = json[SerializationKeys.isLike].boolValue
    username = json[SerializationKeys.username].string
    likeCount = json[SerializationKeys.likeCount].int
    latitude = json[SerializationKeys.latitude].string
    location = json[SerializationKeys.location].string
    postDesc = json[SerializationKeys.postDesc].string
    postId = json[SerializationKeys.postId].string
    image = json[SerializationKeys.image].string
    if let items = json[SerializationKeys.postImages].array { postImages = items.map { PostImages(json: $0) } }
    postDescIos = json[SerializationKeys.postDescIos].string
    creationDatetime = json[SerializationKeys.creationDatetime].string
    commentCount = json[SerializationKeys.commentCount].int
    isDeleted = json[SerializationKeys.isDeleted].string
    userId = json[SerializationKeys.userId].string
    modificationDatetime = json[SerializationKeys.modificationDatetime].string
    longitude = json[SerializationKeys.longitude].string
    imagePath = json[SerializationKeys.imagePath].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = mapImage { dictionary[SerializationKeys.mapImage] = value }
    if let value = peopleTags { dictionary[SerializationKeys.peopleTags] = value }
    if let value = fullName { dictionary[SerializationKeys.fullName] = value }
    if let value = postType { dictionary[SerializationKeys.postType] = value }
    dictionary[SerializationKeys.isLike] = isLike
    if let value = username { dictionary[SerializationKeys.username] = value }
    if let value = likeCount { dictionary[SerializationKeys.likeCount] = value }
    if let value = latitude { dictionary[SerializationKeys.latitude] = value }
    if let value = location { dictionary[SerializationKeys.location] = value }
    if let value = postDesc { dictionary[SerializationKeys.postDesc] = value }
    if let value = postId { dictionary[SerializationKeys.postId] = value }
    if let value = image { dictionary[SerializationKeys.image] = value }
    if let value = postImages { dictionary[SerializationKeys.postImages] = value.map { $0.dictionaryRepresentation() } }
    if let value = postDescIos { dictionary[SerializationKeys.postDescIos] = value }
    if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
    if let value = commentCount { dictionary[SerializationKeys.commentCount] = value }
    if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
    if let value = userId { dictionary[SerializationKeys.userId] = value }
    if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
    if let value = longitude { dictionary[SerializationKeys.longitude] = value }
    if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.mapImage = aDecoder.decodeObject(forKey: SerializationKeys.mapImage) as? String
    self.peopleTags = aDecoder.decodeObject(forKey: SerializationKeys.peopleTags) as? [PeopleTags]
    self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
    self.postType = aDecoder.decodeObject(forKey: SerializationKeys.postType) as? String
    self.isLike = aDecoder.decodeBool(forKey: SerializationKeys.isLike)
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
    self.likeCount = aDecoder.decodeObject(forKey: SerializationKeys.likeCount) as? Int
    self.latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
    self.location = aDecoder.decodeObject(forKey: SerializationKeys.location) as? String
    self.postDesc = aDecoder.decodeObject(forKey: SerializationKeys.postDesc) as? String
    self.postId = aDecoder.decodeObject(forKey: SerializationKeys.postId) as? String
    self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
    self.postImages = aDecoder.decodeObject(forKey: SerializationKeys.postImages) as? [PostImages]
    self.postDescIos = aDecoder.decodeObject(forKey: SerializationKeys.postDescIos) as? String
    self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
    self.commentCount = aDecoder.decodeObject(forKey: SerializationKeys.commentCount) as? Int
    self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
    self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
    self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
    self.longitude = aDecoder.decodeObject(forKey: SerializationKeys.longitude) as? String
    self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(mapImage, forKey: SerializationKeys.mapImage)
    aCoder.encode(peopleTags, forKey: SerializationKeys.peopleTags)
    aCoder.encode(fullName, forKey: SerializationKeys.fullName)
    aCoder.encode(postType, forKey: SerializationKeys.postType)
    aCoder.encode(isLike, forKey: SerializationKeys.isLike)
    aCoder.encode(username, forKey: SerializationKeys.username)
    aCoder.encode(likeCount, forKey: SerializationKeys.likeCount)
    aCoder.encode(latitude, forKey: SerializationKeys.latitude)
    aCoder.encode(location, forKey: SerializationKeys.location)
    aCoder.encode(postDesc, forKey: SerializationKeys.postDesc)
    aCoder.encode(postId, forKey: SerializationKeys.postId)
    aCoder.encode(image, forKey: SerializationKeys.image)
    aCoder.encode(postImages, forKey: SerializationKeys.postImages)
    aCoder.encode(postDescIos, forKey: SerializationKeys.postDescIos)
    aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
    aCoder.encode(commentCount, forKey: SerializationKeys.commentCount)
    aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
    aCoder.encode(userId, forKey: SerializationKeys.userId)
    aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
    aCoder.encode(longitude, forKey: SerializationKeys.longitude)
    aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
  }

}
