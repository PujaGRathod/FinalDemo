//
//  CD_CallHistory+CoreDataProperties.swift
//  
//
//  Created by Admin on 13/07/18.
//
//

import Foundation
import CoreData


extension CD_CallHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_CallHistory> {
        return NSFetchRequest<CD_CallHistory>(entityName: "CD_CallHistory")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var date: String?
    @NSManaged public var is_video_call: String?
    @NSManaged public var call_from: String?
    @NSManaged public var call_to: String?
    @NSManaged public var call_id: String?
    @NSManaged public var isseen: String?
}
