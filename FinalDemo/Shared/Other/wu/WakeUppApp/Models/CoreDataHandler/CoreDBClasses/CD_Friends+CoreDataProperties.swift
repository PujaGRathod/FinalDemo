//
//  CD_Friends+CoreDataProperties.swift
//  
//
//  Created by Admin on 31/03/18.
//
//

import Foundation
import CoreData


extension CD_Friends {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Friends> {
        return NSFetchRequest<CD_Friends>(entityName: "CD_Friends")
    }

    @NSManaged public var user_id: String?
    @NSManaged public var chatid: String?
    @NSManaged public var createddate: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var is_online: String?
    @NSManaged public var isdeleted: String?
    @NSManaged public var isread: String?
    @NSManaged public var last_login: String?
    @NSManaged public var mediaurl: String?
    @NSManaged public var messagetype: String?
    @NSManaged public var platform: String?
    @NSManaged public var receiverid: String?
    @NSManaged public var senderid: String?
    @NSManaged public var textmessage: String?
    @NSManaged public var username: String?
    @NSManaged public var unreadCount: String?
    @NSManaged public var muted_by_me: String?
    @NSManaged public var countrycode: String?
    @NSManaged public var phonenumber: String?
    @NSManaged public var blocked_contacts: String?
    @NSManaged public var ishidden: String?
    @NSManaged public var ispinned: String?
    @NSManaged public var bio: String?
    
    //--->
    @NSManaged public var about_privacy: String?
    @NSManaged public var photo_privacy: String?
    @NSManaged public var read_receipts_privacy: String?
    @NSManaged public var status_privacy: String?
    @NSManaged public var lastseen_privacy: String?

}
