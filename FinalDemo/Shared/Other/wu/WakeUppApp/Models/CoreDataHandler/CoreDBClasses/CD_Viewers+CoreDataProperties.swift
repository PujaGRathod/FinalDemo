//
//  CD_Viewers+CoreDataProperties.swift
//  
//
//  Created by Payal Umraliya on 29/05/18.
//
//

import Foundation
import CoreData


extension CD_Viewers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_Viewers> {
        return NSFetchRequest<CD_Viewers>(entityName: "CD_Viewers")
    }

    @NSManaged public var story_id: String?
    @NSManaged public var viewer_id: String?
    @NSManaged public var viewer_profile: String?
    @NSManaged public var viewer_name: String?
    @NSManaged public var view_date: String?

}
