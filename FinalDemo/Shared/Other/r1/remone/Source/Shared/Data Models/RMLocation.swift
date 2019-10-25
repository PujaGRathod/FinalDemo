//
//  RMLocation.swift
//  remone
//
//  Created by Arjav Lad on 25/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation

//struct RMLocation: Hashable {
//    
//    let id: String
//    let name: String
//    let company: RMCompany
//
//    init?(with data: [String: Any]) {
//        if let nameString = data.stringValue(forkey: "name"),
//            let idString = data.stringValue(forkey: "id") {
//            self.id = idString
//            self.name = nameString
//            if let compData = data["company"] as? [String: Any],
//                let comp = RMCompany.init(with: compData) {
//                self.company = comp
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
//
//    func getRawData() -> [String: Any] {
//        var rawData: [String: Any] = [:]
//        rawData["id"] = self.id
//        rawData["name"] = self.name
//        rawData["company"] = self.company.getRawData()
//        return rawData
//    }
//    
//    var hashValue: Int {
//        return "\(self.id),\(self.name),\(self.company.id),\(self.company.name)".hashValue
//    }
//    
//    static func ==(lhs: RMLocation, rhs: RMLocation) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//}
