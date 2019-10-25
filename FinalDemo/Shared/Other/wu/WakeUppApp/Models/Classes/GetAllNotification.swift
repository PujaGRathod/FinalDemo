//
//  GetAllNotification.swift
//
//  Created by C025 on 14/06/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GetAllNotification: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let newCount = "new_count"
    static let today = "today"
    static let all = "all"
    static let yesterday = "yesterday"
  }

  // MARK: Properties
  public var newCount: Int?
  public var today: [Today]?
  public var all: [All]?
  public var yesterday: [Yesterday]?

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
    newCount = json[SerializationKeys.newCount].int
    if let items = json[SerializationKeys.today].array { today = items.map { Today(json: $0) } }
    if let items = json[SerializationKeys.all].array { all = items.map { All(json: $0) } }
    if let items = json[SerializationKeys.yesterday].array { yesterday = items.map { Yesterday(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = newCount { dictionary[SerializationKeys.newCount] = value }
    if let value = today { dictionary[SerializationKeys.today] = value.map { $0.dictionaryRepresentation() } }
    if let value = all { dictionary[SerializationKeys.all] = value.map { $0.dictionaryRepresentation() } }
    if let value = yesterday { dictionary[SerializationKeys.yesterday] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.newCount = aDecoder.decodeObject(forKey: SerializationKeys.newCount) as? Int
    self.today = aDecoder.decodeObject(forKey: SerializationKeys.today) as? [Today]
    self.all = aDecoder.decodeObject(forKey: SerializationKeys.all) as? [All]
    self.yesterday = aDecoder.decodeObject(forKey: SerializationKeys.yesterday) as? [Yesterday]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(newCount, forKey: SerializationKeys.newCount)
    aCoder.encode(today, forKey: SerializationKeys.today)
    aCoder.encode(all, forKey: SerializationKeys.all)
    aCoder.encode(yesterday, forKey: SerializationKeys.yesterday)
  }

}
