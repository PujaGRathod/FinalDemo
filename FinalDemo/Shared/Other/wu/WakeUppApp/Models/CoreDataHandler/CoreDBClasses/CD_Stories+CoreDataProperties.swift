//
//  CD_Stories+CoreDataProperties.swift
//  
//
//  Created by Admin on 05/06/18.
//
//

import Foundation
import CoreData


extension CD_Stories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Stories> {
        return NSFetchRequest<CD_Stories>(entityName: "CD_Stories")
    }

    @NSManaged public var duration:String?
    @NSManaged public var storyID: String?
    @NSManaged public var userID: String?
    @NSManaged public var createdDate: String?
    @NSManaged public var storyType: String?
    @NSManaged public var mediaURL: String?
    @NSManaged public var isViewedByMe: String?
    @NSManaged public var profileURL: String?
    @NSManaged public var userName: String?
    @NSManaged public var allowcopy: String?
    @NSManaged public var caption: String?
    @NSManaged public var statusprivacy: String?
    @NSManaged public var countrycode: String?
    @NSManaged public var phoneno: String?
    @NSManaged public var statusviewprivacy: String?
    @NSManaged public var markedusers: String?
}
