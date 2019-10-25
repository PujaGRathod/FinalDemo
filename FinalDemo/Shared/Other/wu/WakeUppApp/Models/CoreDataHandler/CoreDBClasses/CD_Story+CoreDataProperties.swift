//
//  CD_Story+CoreDataProperties.swift
//  
//
//  Created by Payal Umraliya on 22/05/18.
//
//

import Foundation
import CoreData


extension CD_Story {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Story> {
        return NSFetchRequest<CD_Story>(entityName: "CD_Story")
    }

    @NSManaged public var kstoryid: String?
    @NSManaged public var kstorytype: String?
    @NSManaged public var kstoryurl: String?
    @NSManaged public var kstoryduration: String?
    @NSManaged public var kstorydate: String?
    @NSManaged public var kuid: String?
    @NSManaged public var kuprofile: String?
    @NSManaged public var kuname: String?
    @NSManaged public var kisviewed: String?
    @NSManaged public var kviewerid: String?
     @NSManaged public var kstoryownername: String?
     @NSManaged public var kstoryownerprofile: String?
     @NSManaged public var kviewtime: String?
    
}
