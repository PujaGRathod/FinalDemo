//
//  CD_GroupMessages+CoreDataProperties.swift
//  
//
//  Created by Admin on 21/07/18.
//
//

import Foundation
import CoreData


extension CD_GroupMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_GroupMessages> {
        return NSFetchRequest<CD_GroupMessages>(entityName: "CD_GroupMessages")
    }

    @NSManaged public var createddate: String?
    @NSManaged public var groupid: String?
    @NSManaged public var id: String?
    @NSManaged public var isdeleted: String?
    @NSManaged public var isread: String?
    @NSManaged public var isstarred: String?
    @NSManaged public var mediaurl: String?
    @NSManaged public var messagetype: String?
    @NSManaged public var parent_id: String?
    @NSManaged public var platform: String?
    @NSManaged public var receiverid: String?
    @NSManaged public var senderid: String?
    @NSManaged public var sendername: String?
    @NSManaged public var textmessage: String?
    @NSManaged public var countrycode: String?
    @NSManaged public var phonenumber: String?
    @NSManaged public var mediasize: String?
}
