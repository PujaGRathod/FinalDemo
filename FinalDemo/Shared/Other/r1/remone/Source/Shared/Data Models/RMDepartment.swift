//
//  RMDepartment.swift
//  remone
//
//  Created by Arjav Lad on 24/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation

struct RMDepartment: Equatable {
    let id: String
    let name: String
    var company: RMCompany?

    init?(with data: [String: Any]) {
        if let nameString = data.stringValue(forkey: "name"),
            let idString = data.stringValue(forkey: "id") {
            self.id = idString
            self.name = nameString
            if let compData = data["company"] as? [String: Any],
                let comp = RMCompany.init(with: compData) {
                self.company = comp
            }
        } else {
            return nil
        }
    }

    func getRawData() -> [String: Any] {
        var rawData: [String: Any] = [:]
        rawData["id"] = self.id
        rawData["name"] = self.name
        if let company = self.company {
            rawData["company"] = company.getRawData()
        }
        return rawData
    }

    static func ==(lhs: RMDepartment, rhs: RMDepartment) -> Bool {
        return (lhs.id == rhs.id)
    }
}
