//
//  CommentData.swift
//
//  Created by C025 on 11/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class CommentData: NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let fullName = "full_name"
        static let channelVideoId = "channel_video_id"
        static let username = "username"
        static let userAction = "user_action"
        static let id = "id"
        static let image = "image"
        static let isFollowing = "is_following"
        static let commentVal = "comment_val"
        static let isDeleted = "is_deleted"
        static let creationDatetime = "creation_datetime"
        static let userId = "user_id"
        static let modificationDatetime = "modification_datetime"
        static let imagePath = "image_path"
    }
    
    // MARK: Properties
    public var fullName: String?
    public var channelVideoId: String?
    public var username: String?
    public var userAction: String?
    public var id: String?
    public var image: String?
    public var isFollowing: Bool? = false
    public var commentVal: String?
    public var isDeleted: String?
    public var creationDatetime: String?
    public var userId: String?
    public var modificationDatetime: String?
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
        fullName = json[SerializationKeys.fullName].string
        channelVideoId = json[SerializationKeys.channelVideoId].string
        username = json[SerializationKeys.username].string
        userAction = json[SerializationKeys.userAction].string
        id = json[SerializationKeys.id].string
        image = json[SerializationKeys.image].string
        isFollowing = json[SerializationKeys.isFollowing].boolValue
        commentVal = json[SerializationKeys.commentVal].string
        isDeleted = json[SerializationKeys.isDeleted].string
        creationDatetime = json[SerializationKeys.creationDatetime].string
        userId = json[SerializationKeys.userId].string
        modificationDatetime = json[SerializationKeys.modificationDatetime].string
        imagePath = json[SerializationKeys.imagePath].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = fullName { dictionary[SerializationKeys.fullName] = value }
        if let value = channelVideoId { dictionary[SerializationKeys.channelVideoId] = value }
        if let value = username { dictionary[SerializationKeys.username] = value }
        if let value = userAction { dictionary[SerializationKeys.userAction] = value }
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = image { dictionary[SerializationKeys.image] = value }
        dictionary[SerializationKeys.isFollowing] = isFollowing
        if let value = commentVal { dictionary[SerializationKeys.commentVal] = value }
        if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
        if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
        if let value = userId { dictionary[SerializationKeys.userId] = value }
        if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
        if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
        self.channelVideoId = aDecoder.decodeObject(forKey: SerializationKeys.channelVideoId) as? String
        self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
        self.userAction = aDecoder.decodeObject(forKey: SerializationKeys.userAction) as? String
        self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
        self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
        self.isFollowing = aDecoder.decodeBool(forKey: SerializationKeys.isFollowing)
        self.commentVal = aDecoder.decodeObject(forKey: SerializationKeys.commentVal) as? String
        self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
        self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
        self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
        self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
        self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(fullName, forKey: SerializationKeys.fullName)
        aCoder.encode(channelVideoId, forKey: SerializationKeys.channelVideoId)
        aCoder.encode(username, forKey: SerializationKeys.username)
        aCoder.encode(userAction, forKey: SerializationKeys.userAction)
        aCoder.encode(id, forKey: SerializationKeys.id)
        aCoder.encode(image, forKey: SerializationKeys.image)
        aCoder.encode(isFollowing, forKey: SerializationKeys.isFollowing)
        aCoder.encode(commentVal, forKey: SerializationKeys.commentVal)
        aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
        aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
        aCoder.encode(userId, forKey: SerializationKeys.userId)
        aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
        aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
    }
    
}

