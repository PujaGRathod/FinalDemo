//
//  Members.swift
//
//  Created by C025 on 11/07/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Members: NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let isAdmin = "is_admin"
        static let phoneno = "phoneno"
        static let countryCode = "country_code"
        static let image = "image"
        static let fullName = "full_name"
        static let finalPhone = "final_phone"
        static let userId = "user_id"
        static let imagePath = "image_path"
        static let username = "username"
        static let bio = "bio"
    }
    
    // MARK: Properties
    public var isAdmin: Bool? = false
    public var phoneno: String?
    public var countryCode: String?
    public var image: String?
    public var fullName: String?
    public var finalPhone: String?
    public var userId: String?
    public var imagePath: String?
    public var username: String?
    public var bio: String?
    
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
        isAdmin = json[SerializationKeys.isAdmin].boolValue
        phoneno = json[SerializationKeys.phoneno].string
        countryCode = json[SerializationKeys.countryCode].string
        image = json[SerializationKeys.image].string
        fullName = json[SerializationKeys.fullName].string
        finalPhone = json[SerializationKeys.finalPhone].string
        userId = "\(json[SerializationKeys.userId])"
        imagePath = Get_Profile_Pic_URL + (image ?? "")
        username = json[SerializationKeys.username].string
        bio = json[SerializationKeys.bio].string
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[SerializationKeys.isAdmin] = isAdmin
        if let value = phoneno { dictionary[SerializationKeys.phoneno] = value }
        if let value = countryCode { dictionary[SerializationKeys.countryCode] = value }
        if let value = image { dictionary[SerializationKeys.image] = value }
        if let value = fullName { dictionary[SerializationKeys.fullName] = value }
        if let value = finalPhone { dictionary[SerializationKeys.finalPhone] = value }
        if let value = userId { dictionary[SerializationKeys.userId] = value }
        if let value = imagePath { dictionary[SerializationKeys.imagePath] = value }
        if let value = username { dictionary[SerializationKeys.username] = value }
        if let value = bio { dictionary[SerializationKeys.bio] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.isAdmin = aDecoder.decodeBool(forKey: SerializationKeys.isAdmin)
        self.phoneno = aDecoder.decodeObject(forKey: SerializationKeys.phoneno) as? String
        self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
        self.image = aDecoder.decodeObject(forKey: SerializationKeys.image) as? String
        self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
        self.finalPhone = aDecoder.decodeObject(forKey: SerializationKeys.finalPhone) as? String
        self.userId = aDecoder.decodeObject(forKey: SerializationKeys.userId) as? String
        self.imagePath = aDecoder.decodeObject(forKey: SerializationKeys.imagePath) as? String
        self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
        self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(isAdmin, forKey: SerializationKeys.isAdmin)
        aCoder.encode(phoneno, forKey: SerializationKeys.phoneno)
        aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
        aCoder.encode(image, forKey: SerializationKeys.image)
        aCoder.encode(fullName, forKey: SerializationKeys.fullName)
        aCoder.encode(finalPhone, forKey: SerializationKeys.finalPhone)
        aCoder.encode(userId, forKey: SerializationKeys.userId)
        aCoder.encode(imagePath, forKey: SerializationKeys.imagePath)
        aCoder.encode(username, forKey: SerializationKeys.username)
        aCoder.encode(bio, forKey: SerializationKeys.bio)
    }
    
}
