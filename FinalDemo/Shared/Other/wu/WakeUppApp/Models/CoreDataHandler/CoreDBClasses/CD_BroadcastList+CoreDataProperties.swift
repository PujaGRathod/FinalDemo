//
//  CD_BroadcastList+CoreDataProperties.swift
//  
//
//  Created by Admin on 28/05/18.
//
//

import Foundation
import CoreData


extension CD_BroadcastList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_BroadcastList> {
        return NSFetchRequest<CD_BroadcastList>(entityName: "CD_BroadcastList")
    }

    @NSManaged public var broadcastListID: String?
    @NSManaged public var name: String?
    @NSManaged public var members: String?
    @NSManaged public var memberNames: String?
    @NSManaged public var memberPhotos: String?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastMessageType: String?
    @NSManaged public var lastMessageDate: String?
    @NSManaged public var lastMessageId: String?
    @NSManaged public var lastMediaURL: String?
    @NSManaged public var ispinned: String?

}
