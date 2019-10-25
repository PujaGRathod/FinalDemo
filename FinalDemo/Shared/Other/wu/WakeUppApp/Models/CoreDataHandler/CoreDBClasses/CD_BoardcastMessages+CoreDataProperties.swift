//
//  CD_BoardcastMessages+CoreDataProperties.swift
//  
//
//  Created by Admin on 28/05/18.
//
//

import Foundation
import CoreData


extension CD_BoardcastMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_BoardcastMessages> {
        return NSFetchRequest<CD_BoardcastMessages>(entityName: "CD_BoardcastMessages")
    }

    @NSManaged public var createddate: String?
    @NSManaged public var broadcastListID: String?
    @NSManaged public var id: String?
    @NSManaged public var isdeleted: String?
    @NSManaged public var isread: String?
    @NSManaged public var mediaurl: String?
    @NSManaged public var messagetype: String?
    @NSManaged public var platform: String?
    @NSManaged public var receiverid: String?
    @NSManaged public var senderid: String?
    @NSManaged public var sendername: String?
    @NSManaged public var textmessage: String?
    @NSManaged public var mediasize: String?
}
