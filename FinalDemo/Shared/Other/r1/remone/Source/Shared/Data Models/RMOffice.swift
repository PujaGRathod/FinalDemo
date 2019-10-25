//
//  RMOffice.swift
//  remone
//
//  Created by Arjav Lad on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import MapKit

struct OfficeLocation {
    var coordinates: CLLocationCoordinate2D
    var address: String
}

class OfficeSeatingType: NSObject, NSCopying {

    let imageURL: URL?
    var image: UIImage?
    let name: String
    let id: String
    var isSelected: Bool = false

    init?(with data: [String: Any]) {
        if let nameString = data.stringValue(forkey: "name"),
            let idString = data.stringValue(forkey: "id") {

            self.name = nameString
            self.id = idString
            if let imgUrlString = data.stringValue(forkey: "image") {
                self.imageURL = URL(string: imgUrlString)
            } else {
                self.imageURL = nil
            }

        } else {
            return nil
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let seatType = OfficeSeatingType.init(with: self.getRawData())!
        seatType.isSelected = self.isSelected
        seatType.image = self.image
        return seatType
    }

    func getRawData() -> [String: Any] {
        var rawData: [String: Any] = [:]
        rawData["id"] = self.id
        rawData["name"] = self.name
        rawData["image"] = self.imageURL
        return rawData
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? OfficeSeatingType {
            return (self.id == obj.id)
        }
        return false
    }
}

class OfficeEquipment: NSObject, NSCopying {
    let imageURL: URL
    let name: String
    let id: String
    var value: String?
    var unit: String?
    var isSelected: Bool = false

    init?(with data: [String: Any]) {
        if let nameString = data.stringValue(forkey: "name"),
            let idString = data.stringValue(forkey: "id"),
            let imgUrlString = data.stringValue(forkey: "url"),
            let imageURL = URL(string: imgUrlString) {
            self.name = nameString
            self.id = idString
            self.imageURL = imageURL
        } else {
            return nil
        }

    }

    func copy(with zone: NSZone? = nil) -> Any {
        let eqipment = OfficeEquipment.init(with: self.getRawData())!
        eqipment.isSelected = self.isSelected
        eqipment.value = self.value
        eqipment.unit = self.unit
        return eqipment
    }

    func getRawData() -> [String: Any] {
        var rawData: [String: Any] = [:]
        rawData["id"] = self.id
        rawData["name"] = self.name
        rawData["url"] = self.imageURL
        return rawData
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? OfficeEquipment {
            return (self.id == obj.id)
        }
        return false
    }

}

class RMOffice: NSObject {
    let id: String
    let name: String
    let location: OfficeLocation
    var equipments: [OfficeEquipment] = []
    var timings: String = ""
    var isPartnerShop: Bool = false
    var images: [URL] = [URL]()
    var nearestStation: String = ""
    var users: [RMUser] = [RMUser]()
    var numberOfSeats: String = ""
    var locationType: LocationType = .unknown
    var deleted: Bool = false
    var url: URL?

    var isOtherLocation: Bool {
        if self.locationType == .other {
            return true
        } else if self.location.coordinates.latitude == -1 &&
            self.location.coordinates.latitude == -1 {
            return true
        }
        return false
    }

    override init() {
        self.name = "Office Location"
        self.id = "1"
        self.location = OfficeLocation.init(coordinates: CLLocationCoordinate2D.init(latitude: 0, longitude: 0), address: "New York")
        self.locationType = .unknown
    }

    init?(with data: [String: Any]) {
        if let idString = data.stringValue(forkey: "id"),
            let nameString = data.stringValue(forkey: "name") {
            self.id = idString
            self.name = nameString

            if let del = data["deleted"] as? Bool {
                self.deleted = del
            } else {
                self.deleted = false
            }
//            if let locString = data.stringValue(forkey: "locationType"),
//                let type = LocationType.init(rawValue: locString) {
//                self.locationType = type
//            } else {
//            }
            self.locationType = LocationType(rawValue: data.stringValue(forkey: "locationType") ?? "") ?? .unknown
            let address = data.stringValue(forkey: "address") ?? "-"
            var coordinates: CLLocationCoordinate2D
            if let lat = data["lat"] as? Double,
                let lon = data["lon"] as? Double {
                coordinates = CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
                self.location = OfficeLocation.init(coordinates: coordinates, address: address)
            } else {
                return nil
            }

            if let urlString = data["url"] as? String,
                urlString != "" {
                self.url = nil
                if let tmp = URL.init(string: urlString) {
                    if ["http", "https"].contains(tmp.scheme?.lowercased() ?? "") {
                        self.url = tmp
                    }
                }
            } else {
                self.url = nil
            }

            if let isPartner = data["partnerShop"] as? Bool {
                self.isPartnerShop = isPartner
            } else {
                self.isPartnerShop = false
            }

            if let amenities = data["amenities"] as? [[String: Any]] {
                for amenity in amenities {
                    if let amenityData = amenity["amenity"] as? [String: Any] {
                        if let eqp = OfficeEquipment.init(with: amenityData) {
                            eqp.value = amenity.stringValue(forkey: "value")
                            eqp.unit = amenity.stringValue(forkey: "unit")
                            self.equipments.append(eqp)
                        }
                    }
                }
            }

            self.numberOfSeats = data.stringValue(forkey: "numberOfSeats") ?? "0"

            self.nearestStation = data.stringValue(forkey: "nearestStation") ?? ""
            self.images = [URL]()
            if let imagesData = data["images"] as? [[String: Any]] {
                for imageData in imagesData {
                    if let imageURLString = imageData.stringValue(forkey: "url"),
                        let imageURL = URL.init(string: imageURLString) {
                        self.images.append(imageURL)

                    }
                }
            }

            self.users = [RMUser]()
            if let usersData = data["users"] as? [[String: Any]] {
                for userData in usersData {
                    if let user = RMUser.init(with: userData),
                        user.shouldShowUser {
                        self.users.append(user)
                    }
                }
            }

            if let timings = data["timings"] as? [[String: Any]] {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.init(identifier: "en_US")
                dateFormatter.dateFormat = "EEE"
                let currentDay = dateFormatter.string(from: Date()).capitalized.uppercased()
                for timeDic in timings {
                    if let isEnabled = timeDic["enabled"] as? Bool {
                        if(isEnabled) {
                            if currentDay == timeDic["day"] as? String {
                                if let startHour = timeDic.stringValue(forkey: "startHour"),
                                    let startMin = timeDic.stringValue(forkey: "startMin"),
                                    let endHour = timeDic.stringValue(forkey: "endHour"),
                                    let endMin = timeDic.stringValue(forkey: "endMin") {
//                                    if (startHour == "00" ||
//                                        startHour == "0") &&
//                                        (endHour == "00" ||x
//                                            endHour == "0") &&
//                                        (startMin == "00" ||
//                                            startMin == "0") &&
//                                        (endMin == "00" ||
//                                            endMin == "0") {
//                                        self.timings = "Closed".localized
//                                    } else {
                                    if startHour.correctTime() == endHour.correctTime() &&
                                        startMin.correctTime() == endMin.correctTime() {
                                        self.timings = "24 hours open".localized
                                    } else {
                                        self.timings = "\(startHour.correctTime()):\(startMin.correctTime()) - \(endHour.correctTime()):\(endMin.correctTime())"
                                    }
//                                    }
                                    break;
                                }
                            } else {
                                self.timings = "Closed".localized
                            }
                        } else {
                            self.timings = "Closed".localized
                        }
                    }
                }
            } else {
                self.timings = "Closed".localized
            }

        } else {
            return nil
        }
    }

    func convertToCompany() -> RMCompany? {
        var rawData: [String: Any] = [:]
        rawData["name"] = self.name
        rawData["id"] = self.id
        rawData["lat"] = self.location.coordinates.latitude
        rawData["lon"] = self.location.coordinates.longitude
        rawData["address"] = self.location.address
        rawData["nearestStation"] = self.nearestStation
        
        return RMCompany.init(with: rawData)
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let office2 = object as? RMOffice {
            if office2.id == self.id {
                return true
            }
        }
        return false
    }

}

