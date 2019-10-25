//
//  CD_Messages+CoreDataProperties.swift
//  
//
//  Created by Admin on 31/03/18.
//
//

import Foundation
import CoreData


extension CD_Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Messages> {
        return NSFetchRequest<CD_Messages>(entityName: "CD_Messages")
    }

    @NSManaged public var id: String?
    @NSManaged public var createddate: String?
    @NSManaged public var platform: String?
    @NSManaged public var textmessage: String?
    @NSManaged public var receiverid: String?
    @NSManaged public var senderid: String?
    @NSManaged public var sendername: String?
    @NSManaged public var isdeleted: String?
    @NSManaged public var isread: String?
    @NSManaged public var mediaurl: String?
    @NSManaged public var messagetype: String?
    @NSManaged public var chatid: String?
    @NSManaged public var image: String?
    @NSManaged public var is_online: String?
    @NSManaged public var last_login: String?
    @NSManaged public var username: String?
    @NSManaged public var user_id: String?
    @NSManaged public var isstarred: String?
    @NSManaged public var parentid: String?
    @NSManaged public var mediasize: String?
    @NSManaged public var readtime: String?
    @NSManaged public var receivetime: String?
}
