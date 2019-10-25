//
//  GetSingleChannelVideo.swift
//
//  Created by C025 on 29/05/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetSingleChannelVideo: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let commentData = "comment_data"
    static let descriptionValue = "description"
    static let isLike = "is_like"
    static let channelVideoId = "channel_video_id"
    static let createdUserid = "created_userid"
    static let likeData = "like_data"
    static let channelTitle = "channel_title"
    static let username = "username"
    static let channelId = "channel_id"
    static let likeCount = "like_count"
    static let viewCount = "view_count"
    static let video = "video"
    static let commentCount = "comment_count"
    static let creationDatetime = "creation_datetime"
    static let thumImg = "thum_img"
    static let title = "title"
    static let logo = "logo"
  }

  // MARK: Properties
  public var commentData: [CommentData]?
  public var descriptionValue: String?
  public var isLike: Bool? = false
  public var channelVideoId: String?
  public var createdUserid: String?
  public var likeData: [LikeData]?
  public var channelTitle: String?
  public var username: String?
  public var channelId: String?
  public var likeCount: Int?
  public var viewCount: Int?
  public var video: String?
  public var commentCount: Int?
  public var creationDatetime: String?
  public var thumImg: String?
  public var title: String?
  public var logo: String?

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
    if let items = json[SerializationKeys.commentData].array { commentData = items.map { CommentData(json: $0) } }
    descriptionValue = json[SerializationKeys.descriptionValue].string
    isLike = json[SerializationKeys.isLike].boolValue
    channelVideoId = json[SerializationKeys.channelVideoId].string
    createdUserid = json[SerializationKeys.createdUserid].string
    if let items = json[SerializationKeys.likeData].array { likeData = items.map { LikeData(json: $0) } }
    channelTitle = json[SerializationKeys.channelTitle].string
    username = json[SerializationKeys.username].string
    channelId = json[SerializationKeys.channelId].string
    likeCount = json[SerializationKeys.likeCount].int
    viewCount = json[SerializationKeys.viewCount].int
    video = json[SerializationKeys.video].string
    commentCount = json[SerializationKeys.commentCount].int
    creationDatetime = json[SerializationKeys.creationDatetime].string
    thumImg = json[SerializationKeys.thumImg].string
    title = json[SerializationKeys.title].string
    logo = json[SerializationKeys.logo].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = commentData { dictionary[SerializationKeys.commentData] = value.map { $0.dictionaryRepresentation() } }
    if let value = descriptionValue { dictionary[SerializationKeys.descriptionValue] = value }
    dictionary[SerializationKeys.isLike] = isLike
    if let value = channelVideoId { dictionary[SerializationKeys.channelVideoId] = value }
    if let value = createdUserid { dictionary[SerializationKeys.createdUserid] = value }
    if let value = likeData { dictionary[SerializationKeys.likeData] = value.map { $0.dictionaryRepresentation() } }
    if let value = channelTitle { dictionary[SerializationKeys.channelTitle] = value }
    if let value = username { dictionary[SerializationKeys.username] = value }
    if let value = channelId { dictionary[SerializationKeys.channelId] = value }
    if let value = likeCount { dictionary[SerializationKeys.likeCount] = value }
    if let value = viewCount { dictionary[SerializationKeys.viewCount] = value }
    if let value = video { dictionary[SerializationKeys.video] = value }
    if let value = commentCount { dictionary[SerializationKeys.commentCount] = value }
    if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
    if let value = thumImg { dictionary[SerializationKeys.thumImg] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    if let value = logo { dictionary[SerializationKeys.logo] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.commentData = aDecoder.decodeObject(forKey: SerializationKeys.commentData) as? [CommentData]
    self.descriptionValue = aDecoder.decodeObject(forKey: SerializationKeys.descriptionValue) as? String
    self.isLike = aDecoder.decodeBool(forKey: SerializationKeys.isLike)
    self.channelVideoId = aDecoder.decodeObject(forKey: SerializationKeys.channelVideoId) as? String
    self.createdUserid = aDecoder.decodeObject(forKey: SerializationKeys.createdUserid) as? String
    self.likeData = aDecoder.decodeObject(forKey: SerializationKeys.likeData) as? [LikeData]
    self.channelTitle = aDecoder.decodeObject(forKey: SerializationKeys.channelTitle) as? String
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
    self.channelId = aDecoder.decodeObject(forKey: SerializationKeys.channelId) as? String
    self.likeCount = aDecoder.decodeObject(forKey: SerializationKeys.likeCount) as? Int
    self.viewCount = aDecoder.decodeObject(forKey: SerializationKeys.viewCount) as? Int
    self.video = aDecoder.decodeObject(forKey: SerializationKeys.video) as? String
    self.commentCount = aDecoder.decodeObject(forKey: SerializationKeys.commentCount) as? Int
    self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
    self.thumImg = aDecoder.decodeObject(forKey: SerializationKeys.thumImg) as? String
    self.title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
    self.logo = aDecoder.decodeObject(forKey: SerializationKeys.logo) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(commentData, forKey: SerializationKeys.commentData)
    aCoder.encode(descriptionValue, forKey: SerializationKeys.descriptionValue)
    aCoder.encode(isLike, forKey: SerializationKeys.isLike)
    aCoder.encode(channelVideoId, forKey: SerializationKeys.channelVideoId)
    aCoder.encode(createdUserid, forKey: SerializationKeys.createdUserid)
    aCoder.encode(likeData, forKey: SerializationKeys.likeData)
    aCoder.encode(channelTitle, forKey: SerializationKeys.channelTitle)
    aCoder.encode(username, forKey: SerializationKeys.username)
    aCoder.encode(channelId, forKey: SerializationKeys.channelId)
    aCoder.encode(likeCount, forKey: SerializationKeys.likeCount)
    aCoder.encode(viewCount, forKey: SerializationKeys.viewCount)
    aCoder.encode(video, forKey: SerializationKeys.video)
    aCoder.encode(commentCount, forKey: SerializationKeys.commentCount)
    aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
    aCoder.encode(thumImg, forKey: SerializationKeys.thumImg)
    aCoder.encode(title, forKey: SerializationKeys.title)
    aCoder.encode(logo, forKey: SerializationKeys.logo)
  }

}
