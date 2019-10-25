//
//  PostImages.swift
//
//  Created by C025 on 25/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class PostImages: NSObject, NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let postImage = "post_image"
        static let postId = "post_id"
        static let imageType = "image_type"
        static let id = "id"
        static let isDeleted = "is_deleted"
        static let creationDatetime = "creation_datetime"
        static let modificationDatetime = "modification_datetime"
        static let imagePath = "image_path"
    }
    
    // MARK: Properties
    public var postImage: String?
    public var postId: String?
    public var imageType: String?
    public var id: String?
    public var isDeleted: String?
    public var creationDatetime: String?
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
        postImage = json[SerializationKeys.postImage].string
        postId = json[SerializationKeys.postId].string
        imageType = json[SerializationKeys.imageType].string
        id = json[SerializationKeys.id].string
        isDeleted = json[SerializationKeys.isDeleted].string
        creationDatetime = json[SerializationKeys.creationDatetime].string
        modificationDatetime = json[SerializationKeys.modificationDatetime].string
        imagePath = json[SerializationKeys.imagePath].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = postImage { dictionary[SerializationKeys.postImage] = value }
        if let value = postId { dictionary[SerializationKeys.postId] = value }
        if let value = imageType { dictionary[SerializationKeys.imageType] = value }
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
        if let value = creationDatetime { dictionary[SerializationKeys.creationDatetime] = value }
        if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
        if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.postImage = aDecoder.decodeObject(forKey: SerializationKeys.postImage) as? String
        self.postId = aDecoder.decodeObject(forKey: SerializationKeys.postId) as? String
        self.imageType = aDecoder.decodeObject(forKey: SerializationKeys.imageType) as? String
        self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
        self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
        self.creationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.creationDatetime) as? String
        self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
        self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(postImage, forKey: SerializationKeys.postImage)
        aCoder.encode(postId, forKey: SerializationKeys.postId)
        aCoder.encode(imageType, forKey: SerializationKeys.imageType)
        aCoder.encode(id, forKey: SerializationKeys.id)
        aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
        aCoder.encode(creationDatetime, forKey: SerializationKeys.creationDatetime)
        aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
        aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
    }
    
}

