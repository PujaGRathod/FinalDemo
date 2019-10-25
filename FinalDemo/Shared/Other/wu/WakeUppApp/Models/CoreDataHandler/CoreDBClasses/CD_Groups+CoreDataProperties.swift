//
//  CD_Groups+CoreDataProperties.swift
//  
//
//  Created by Admin on 24/04/18.
//
//

import Foundation
import CoreData

extension CD_Groups {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Groups> {
        return NSFetchRequest<CD_Groups>(entityName: "CD_Groups")
    }

    @NSManaged public var group_id: String?
    @NSManaged public var name: String?
    @NSManaged public var icon: String?
    @NSManaged public var members: String?
    @NSManaged public var muted_by: String?
    @NSManaged public var createdby: String?
    @NSManaged public var admins: String?
    @NSManaged public var isalladmin: String?
    @NSManaged public var isdelete: String?
    @NSManaged public var lastMessageId: String?
    @NSManaged public var lastMediaURL: String?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastMessageDate: String?
    @NSManaged public var lastMessageType: String?
    @NSManaged public var lastMessageSenderId: String?
    @NSManaged public var lastMessageReceiverIds: String?
    @NSManaged public var unreadCount: String?
    @NSManaged public var ishidden: String?
    @NSManaged public var ispinned: String?
    @NSManaged public var edit_permission: String?
    @NSManaged public var msg_permission: String?
    
}
