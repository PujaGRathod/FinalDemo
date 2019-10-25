//
//  CD_Stories_Viewers+CoreDataProperties.swift
//  
//
//  Created by Admin on 05/06/18.
//
//

import Foundation
import CoreData


extension CD_Stories_Viewers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Stories_Viewers> {
        return NSFetchRequest<CD_Stories_Viewers>(entityName: "CD_Stories_Viewers")
    }

    @NSManaged public var createdDate: String?
    @NSManaged public var storyID: String?
    @NSManaged public var userID: String?
    @NSManaged public var profileURL: String?
    @NSManaged public var userName: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var phoneNo: String?
}
