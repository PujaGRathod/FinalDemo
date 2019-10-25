//
//  GroupInfo.swift
//
//  Created by Admin on 22/05/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GroupInfo: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let icon = "icon"
    static let name = "name"
    static let fullName = "full_name"
    static let groupId = "group_id"
    static let admins = "admins"
    static let mutedBy = "muted_by"
    static let username = "username"
    static let modifyDate = "modify_date"
    static let groupMembers = "group_members"
    static let isalladmin = "isalladmin"
    static let isDeleted = "is_deleted"
    static let createdby = "createdby"
    static let createddate = "createddate"
    static let modificationDatetime = "modification_datetime"
    static let isdelete = "isdelete"
    static let members = "members"
    static let edit_permission = "edit_permission"
    static let msg_permission = "msg_permission"
  }

  // MARK: Properties
  public var icon: String?
  public var name: String?
  public var fullName: String?
  public var groupId: String?
  public var admins: String?
  public var mutedBy: String?
  public var username: String?
  public var modifyDate: String?
  public var groupMembers: String?
  public var isalladmin: String?
  public var isDeleted: String?
  public var createdby: String?
  public var createddate: String?
  public var modificationDatetime: String?
  public var isdelete: String?
  public var members: [Members]?
  public var edit_permission: String?
  public var msg_permission: String?
    

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
    icon = json[SerializationKeys.icon].string
    name = json[SerializationKeys.name].string
    fullName = json[SerializationKeys.fullName].string
    groupId = "\(json[SerializationKeys.groupId])"
    admins = json[SerializationKeys.admins].string
    mutedBy = json[SerializationKeys.mutedBy].string
    username = json[SerializationKeys.username].string
    modifyDate = json[SerializationKeys.modifyDate].string
    groupMembers = json[SerializationKeys.groupMembers].string
    isalladmin = json[SerializationKeys.isalladmin].string
    isDeleted = json[SerializationKeys.isDeleted].string
    createdby = "\(json[SerializationKeys.createdby].string ?? "0")"
    createddate = json[SerializationKeys.createddate].string
    modificationDatetime = json[SerializationKeys.modificationDatetime].string
    isdelete = json[SerializationKeys.isdelete].string
    if let items = json[SerializationKeys.members].array { members = items.map { Members(json: $0) } }
    edit_permission = "\(json[SerializationKeys.edit_permission])"
    msg_permission = "\(json[SerializationKeys.msg_permission])"
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = icon { dictionary[SerializationKeys.icon] = value }
    if let value = name { dictionary[SerializationKeys.name] = value }
    if let value = fullName { dictionary[SerializationKeys.fullName] = value }
    if let value = groupId { dictionary[SerializationKeys.groupId] = value }
    if let value = admins { dictionary[SerializationKeys.admins] = value }
    if let value = mutedBy { dictionary[SerializationKeys.mutedBy] = value }
    if let value = username { dictionary[SerializationKeys.username] = value }
    if let value = modifyDate { dictionary[SerializationKeys.modifyDate] = value }
    if let value = groupMembers { dictionary[SerializationKeys.groupMembers] = value }
    if let value = isalladmin { dictionary[SerializationKeys.isalladmin] = value }
    if let value = isDeleted { dictionary[SerializationKeys.isDeleted] = value }
    if let value = createdby { dictionary[SerializationKeys.createdby] = value }
    if let value = createddate { dictionary[SerializationKeys.createddate] = value }
    if let value = modificationDatetime { dictionary[SerializationKeys.modificationDatetime] = value }
    if let value = isdelete { dictionary[SerializationKeys.isdelete] = value }
    if let value = members { dictionary[SerializationKeys.members] = value.map { $0.dictionaryRepresentation() } }
    if let value = edit_permission { dictionary[SerializationKeys.edit_permission] = value }
    if let value = msg_permission { dictionary[SerializationKeys.msg_permission ] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.icon = aDecoder.decodeObject(forKey: SerializationKeys.icon) as? String
    self.name = aDecoder.decodeObject(forKey: SerializationKeys.name) as? String
    self.fullName = aDecoder.decodeObject(forKey: SerializationKeys.fullName) as? String
    self.groupId = aDecoder.decodeObject(forKey: SerializationKeys.groupId) as? String
    self.admins = aDecoder.decodeObject(forKey: SerializationKeys.admins) as? String
    self.mutedBy = aDecoder.decodeObject(forKey: SerializationKeys.mutedBy) as? String
    self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String
    self.modifyDate = aDecoder.decodeObject(forKey: SerializationKeys.modifyDate) as? String
    self.groupMembers = aDecoder.decodeObject(forKey: SerializationKeys.groupMembers) as? String
    self.isalladmin = aDecoder.decodeObject(forKey: SerializationKeys.isalladmin) as? String
    self.isDeleted = aDecoder.decodeObject(forKey: SerializationKeys.isDeleted) as? String
    self.createdby = aDecoder.decodeObject(forKey: SerializationKeys.createdby) as? String
    self.createddate = aDecoder.decodeObject(forKey: SerializationKeys.createddate) as? String
    self.modificationDatetime = aDecoder.decodeObject(forKey: SerializationKeys.modificationDatetime) as? String
    self.isdelete = aDecoder.decodeObject(forKey: SerializationKeys.isdelete) as? String
    self.members = aDecoder.decodeObject(forKey: SerializationKeys.members) as? [Members]
    self.edit_permission = aDecoder.decodeObject(forKey: SerializationKeys.edit_permission) as? String
    self.msg_permission = aDecoder.decodeObject(forKey: SerializationKeys.msg_permission) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(icon, forKey: SerializationKeys.icon)
    aCoder.encode(name, forKey: SerializationKeys.name)
    aCoder.encode(fullName, forKey: SerializationKeys.fullName)
    aCoder.encode(groupId, forKey: SerializationKeys.groupId)
    aCoder.encode(admins, forKey: SerializationKeys.admins)
    aCoder.encode(mutedBy, forKey: SerializationKeys.mutedBy)
    aCoder.encode(username, forKey: SerializationKeys.username)
    aCoder.encode(modifyDate, forKey: SerializationKeys.modifyDate)
    aCoder.encode(groupMembers, forKey: SerializationKeys.groupMembers)
    aCoder.encode(isalladmin, forKey: SerializationKeys.isalladmin)
    aCoder.encode(isDeleted, forKey: SerializationKeys.isDeleted)
    aCoder.encode(createdby, forKey: SerializationKeys.createdby)
    aCoder.encode(createddate, forKey: SerializationKeys.createddate)
    aCoder.encode(modificationDatetime, forKey: SerializationKeys.modificationDatetime)
    aCoder.encode(isdelete, forKey: SerializationKeys.isdelete)
    aCoder.encode(members, forKey: SerializationKeys.members)
    aCoder.encode(edit_permission, forKey: SerializationKeys.edit_permission)
    aCoder.encode(msg_permission, forKey: SerializationKeys.msg_permission)
  }

}
