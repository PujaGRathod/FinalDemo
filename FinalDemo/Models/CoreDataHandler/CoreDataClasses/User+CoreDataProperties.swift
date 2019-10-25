//
//  User+CoreDataProperties.swift
//  FinalDemo
//
//  Created by POOJA on 25/10/19.
//  Copyright © 2019 POOJA. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userId: String?
    @NSManaged public var userName: String?


}
