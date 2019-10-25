//
//  GetChannelVideoCommentsLikes.swift
//
//  Created by C025 on 11/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetChannelVideoCommentsLikes: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let likeCount = "like_count"
    static let viewData = "view_data"
    static let commentData = "comment_data"
    static let likeData = "like_data"
    static let commentCount = "comment_count"
    static let viewCount = "view_count"
  }

  // MARK: Properties
  public var likeCount: Int?
  public var viewData: [ViewData]?
  public var commentData: [CommentData]?
  public var likeData: [LikeData]?
  public var commentCount: Int?
  public var viewCount: Int?

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
    likeCount = json[SerializationKeys.likeCount].int
    if let items = json[SerializationKeys.viewData].array { viewData = items.map { ViewData(json: $0) } }
    if let items = json[SerializationKeys.commentData].array { commentData = items.map { CommentData(json: $0) } }
    if let items = json[SerializationKeys.likeData].array { likeData = items.map { LikeData(json: $0) } }
    commentCount = json[SerializationKeys.commentCount].int
    viewCount = json[SerializationKeys.viewCount].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = likeCount { dictionary[SerializationKeys.likeCount] = value }
    if let value = viewData { dictionary[SerializationKeys.viewData] = value.map { $0.dictionaryRepresentation() } }
    if let value = commentData { dictionary[SerializationKeys.commentData] = value.map { $0.dictionaryRepresentation() } }
    if let value = likeData { dictionary[SerializationKeys.likeData] = value.map { $0.dictionaryRepresentation() } }
    if let value = commentCount { dictionary[SerializationKeys.commentCount] = value }
    if let value = viewCount { dictionary[SerializationKeys.viewCount] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.likeCount = aDecoder.decodeObject(forKey: SerializationKeys.likeCount) as? Int
    self.viewData = aDecoder.decodeObject(forKey: SerializationKeys.viewData) as? [ViewData]
    self.commentData = aDecoder.decodeObject(forKey: SerializationKeys.commentData) as? [CommentData]
    self.likeData = aDecoder.decodeObject(forKey: SerializationKeys.likeData) as? [LikeData]
    self.commentCount = aDecoder.decodeObject(forKey: SerializationKeys.commentCount) as? Int
    self.viewCount = aDecoder.decodeObject(forKey: SerializationKeys.viewCount) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(likeCount, forKey: SerializationKeys.likeCount)
    aCoder.encode(viewData, forKey: SerializationKeys.viewData)
    aCoder.encode(commentData, forKey: SerializationKeys.commentData)
    aCoder.encode(likeData, forKey: SerializationKeys.likeData)
    aCoder.encode(commentCount, forKey: SerializationKeys.commentCount)
    aCoder.encode(viewCount, forKey: SerializationKeys.viewCount)
  }

}
