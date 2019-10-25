//
//  RMCompany.swift
//  remone
//
//  Created by Arjav Lad on 24/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation
import MapKit

enum LocationType: String {
    case owned = "OWNED"
    case underContract = "UNDER_CONTRACT"
    case other = "STATIC"
    case unknown
}

struct RMCompany: Equatable {
    let id: String
    let name: String
    let address: String
    var lattitude: Double?
    var longitude: Double?
    let nearestStation: String
    let openingHour: String
    let closingHour: String
    var locationType: LocationType = .unknown

    var deleted: Bool = false

    var location: CLLocationCoordinate2D? {
        if let lat = self.lattitude,
            let lon = self.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    /// For Static Location only
    init(with name: String, id: String) {
        self.name = name
        self.id = id
        self.address = ""
        self.lattitude = -1
        self.longitude = -1
        self.nearestStation = ""
        self.openingHour = ""
        self.closingHour = ""
        self.locationType = .other
    }

    init?(with data: [String: Any]) {
        if let nameString = data.stringValue(forkey: "name"),
            let idString = data.stringValue(forkey: "id") {

            if let del = data["deleted"] as? Bool {
                self.deleted = del
            } else {
                self.deleted = false
            }

            self.locationType = LocationType.init(rawValue: data.stringValue(forkey: "locationType") ?? "") ?? .unknown
            self.id = idString
            self.name = nameString

            if let lat = data["lat"] as? Double {
                self.lattitude = lat
            } else if let lat = data["lat"] as? Int  {
                self.lattitude = Double(lat)
            } else if let lat = data.stringValue(forkey:  "lat"),
                let latDouble = Double(lat) {
                self.lattitude =  latDouble
            } else {
//                return nil
            }

            if let lon = data["lon"] as? Double {
                self.longitude = lon
            } else if let lon = data["lon"] as? Int  {
                self.longitude = Double(lon)
            } else if let lon = data.stringValue(forkey:  "lon"),
                let lonDouble = Double(lon) {
                self.longitude =  lonDouble
            } else {
//                return nil
            }


            if let add = data.stringValue(forkey: "address") {
                self.address = add
            } else {
                self.address = ""
            }

            if let nearest = data.stringValue(forkey: "nearestStation") {
                self.nearestStation = nearest
            } else {
                self.nearestStation = ""
            }

            self.openingHour = data.stringValue(forkey: "openingHour") ?? ""
            self.closingHour = data.stringValue(forkey: "closingHour") ?? ""

        } else {
            return nil
        }
    }

    func getRawData() -> [String: Any] {
        var rawData: [String: Any] = [:]
        rawData["id"] = self.id
        rawData["name"] = self.name
        rawData["lat"] = self.lattitude
        rawData["lon"] = self.longitude
        rawData["address"] = self.address
        rawData["nearestStation"] = self.nearestStation
        rawData["openingHour"] = self.openingHour
        rawData["closingHour"] = self.closingHour
        rawData["locationType"] = self.locationType.rawValue
        return rawData
    }


    static func getWorkFinishLocation() -> RMCompany {
        return RMCompany.init(with: "-", id: "419")
    }

    static func getOtherTimeStampLocationList() -> [RMCompany] {
        return [RMCompany.init(with: "自宅", id: "374"),
                RMCompany.init(with: "訪問先・出張先", id: "375"),
                RMCompany.init(with: "移動中の交通機関", id: "376"),
                RMCompany.init(with: "飲食店", id: "377")]
    }

    static func getOtherLocationList() -> [RMCompany] {
        return RMCompany.getOtherTimeStampLocationList() + [RMCompany.getWorkFinishLocation()]
    }
    
    var hashValue: Int {
        return "\(self.id),\(self.name)".hashValue
    }
    
    static func ==(lhs: RMCompany, rhs: RMCompany) -> Bool {
        return lhs.id == rhs.id
    }

}

