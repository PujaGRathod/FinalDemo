//
//  OfficeSearchFilter.swift
//  remone
//
//  Created by Arjav Lad on 11/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

struct OfficeSearchHistory: Equatable {
    let id: String
//    let text: String?
    let filter: OfficeSearchFilter?

    var displayText: String {
        var filterText: [String] = [String]()
        if let filter = self.filter {
            if let text = filter.text {
                filterText.append(text)
            }
            
            if filter.showOnlyPartnerStore {
                filterText.append("提携店だけ")
            }

            for day in filter.getSelectedBusinessDays {
                filterText.append(day.key.localized)
            }

            for equipment in filter.getSelectedEquipments {
                filterText.append(equipment.name)
            }

            if filter.openingTime != "00:00",
                filter.closingTime != "00:00" {
                filterText.append("\(filter.openingTime) - \(filter.closingTime)")
            }

        }
        let displayString: String = filterText.joined(separator: ", ")
        return displayString
    }

    init?(with data: [String: Any]) {
        if let idString = data.stringValue(forkey: "id") {
            self.id = idString
//            self.text = data.stringValue(forkey: "text")
            if let filter = OfficeSearchFilter.defaultOfficeSearchFilter.copy() as? OfficeSearchFilter {
                let selectedFilter = OfficeSearchFilter.init(with: data)
                filter.showOnlyPartnerStore = selectedFilter.showOnlyPartnerStore
                filter.openingTime = selectedFilter.openingTime
                filter.closingTime = selectedFilter.openingTime
                filter.text = selectedFilter.text
                for day in filter.businessDays {
                    if selectedFilter.businessDays.contains(day) {
                        day.isSelected = true
                    }
                }

                for equipment in filter.equipments {
                    if selectedFilter.equipments.contains(equipment) {
                        equipment.isSelected = true
                    }
                }

                for seatingType in filter.seatingTypes {
                    if selectedFilter.seatingTypes.contains(seatingType) {
                        seatingType.isSelected = true
                    }
                }

                filter.latitude = selectedFilter.latitude
                filter.longitude = selectedFilter.longitude
                filter.radius = selectedFilter.radius
                self.filter = filter

            } else {
                return nil
            }

            if self.displayText == "" {
                return nil
            }
        } else {
            return nil
        }
    }

    static func ==(lhs: OfficeSearchHistory, rhs: OfficeSearchHistory) -> Bool {
        return lhs.id == rhs.id
    }

}

class OfficeWorkingDays: NSObject, NSCopying {
    let name: String
    let key: String
    var isSelected: Bool = false

    init(key: String, name: String) {
        self.key = key
        self.name = name
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? OfficeWorkingDays {
            return (self.key == obj.key)
        }
        return false
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let keyString = self.key
        let nameString = self.name
        let day = OfficeWorkingDays.init(key: keyString, name: nameString)
        day.isSelected = self.isSelected
        return day
    }
}

class OfficeSearchFilter: NSObject, NSCopying {

    static var defaultOfficeSearchFilter: OfficeSearchFilter!

    var text: String?
    var showOnlyPartnerStore: Bool = false
    var businessDays: [OfficeWorkingDays] = [OfficeWorkingDays]()
    var seatingTypes: [OfficeSeatingType] = [OfficeSeatingType]()
    var equipments: [OfficeEquipment] = [OfficeEquipment]()
    var openingTime: String = "00:00"
    var closingTime: String = "00:00"
    var latitude: Double?
    var longitude: Double?
    var radius: Double?

    var getSelectedEquipments: [OfficeEquipment] {
        return self.equipments.filter({ return $0.isSelected })
    }

    var getSelectedSeating: [OfficeSeatingType] {
        return self.seatingTypes.filter({ return $0.isSelected })
    }

    var getSelectedBusinessDays: [OfficeWorkingDays] {
        return self.businessDays.filter({ return $0.isSelected })
    }

    var isApplied: Bool {
        if self.showOnlyPartnerStore ||
        self.getSelectedBusinessDays.count > 0 ||
        self.getSelectedSeating.count > 0 ||
            self.getSelectedEquipments.count > 0 {
            return true
        }
        
        if self.openingTime.trimString().count > 0 &&
            self.openingTime.trimString() != "00:00" {
            return true
        }
        
        if self.closingTime.trimString().count > 0 &&
            self.closingTime.trimString() != "00:00" {
                return true
        }
        
        if self.latitude != nil &&
            self.longitude != nil
        {
            return true
        }
        
        if self.radius != nil
        {
            return true
        }
        
        return false
    }
    
    override init() {

    }

    func copy(with zone: NSZone? = nil) -> Any {
        let filter = OfficeSearchFilter.init()
        filter.showOnlyPartnerStore = self.showOnlyPartnerStore
        filter.businessDays = self.businessDays.clone()
        filter.seatingTypes = self.seatingTypes.clone()
        filter.equipments = self.equipments.clone()
        filter.openingTime = self.openingTime
        filter.closingTime = self.closingTime
        filter.latitude = self.latitude
        filter.longitude = self.longitude
        filter.radius = self.radius
        return filter
    }

    init(with data: [String: Any]) {
        if let parnerShp = data["partnerStores"] as? Bool {
            self.showOnlyPartnerStore = parnerShp
        } else {
            self.showOnlyPartnerStore = (data["partnerShop"] as? Bool) ?? false
        }

        self.text = data.stringValue(forkey: "text")

        self.businessDays = [OfficeWorkingDays]()
        if let daysData = data.stringValue(forkey: "days") {
            let days = daysData.components(separatedBy: ",")
            for day in days {
                self.businessDays.append(OfficeWorkingDays.init(key: day, name: day))
            }
        }

        if let oTime = data.stringValue(forkey: "openingTime") {
            self.openingTime = oTime
        } else {
            self.openingTime = "00:00"
        }

        if let cTime = data.stringValue(forkey: "closingTime") {
            self.closingTime = cTime
        } else {
            self.closingTime = "00:00"
        }

        self.equipments = [OfficeEquipment]()
        if let amenities = data["amenities"] as? [[String: Any]] {
            for amenityData in amenities {
                if let amenity = OfficeEquipment.init(with: amenityData) {
                    self.equipments.append(amenity)
                }
            }
        }

        self.latitude = data["lat"] as? Double ?? nil
        self.longitude = data["lon"] as? Double ?? nil
        self.radius = data["radius"] as? Double ?? nil
    }

    class func generateStaticFilter(_ completion: @escaping (OfficeSearchFilter)->Void) {
        let filter = OfficeSearchFilter()
        filter.businessDays = [ OfficeWorkingDays.init(key: "MON", name: "Monday".localized),
                                OfficeWorkingDays.init(key: "TUE", name: "Tuesday".localized),
                                OfficeWorkingDays.init(key: "WED", name: "Wendnesday".localized),
                                OfficeWorkingDays.init(key: "THU", name: "Thursday".localized),
                                OfficeWorkingDays.init(key: "FRI", name: "Friday".localized),
                                OfficeWorkingDays.init(key: "SAT", name: "Saturday".localized),
                                OfficeWorkingDays.init(key: "SUN", name: "Sunday".localized)]

        let seatingType1 = OfficeSeatingType(with: ["name":"ブース席", "id":"1"])!
        seatingType1.image = #imageLiteral(resourceName: "iconMeetingCopy")
        let seatingType2 = OfficeSeatingType(with: ["name":"会議室", "id":"2"])!
        seatingType2.image = #imageLiteral(resourceName: "iconMeeting")
        filter.seatingTypes = [seatingType1, seatingType2]

        APIManager.shared.getAllAmenities { (amenities, error) in
            filter.equipments = amenities
            completion(filter)
        }
    }

    func getRawData() -> [String: Any] {
        var rawData = [String: Any]()

        if let searchText = self.text {
            rawData["text"] = searchText
        }

        if self.openingTime != "00:00" &&
           self.openingTime != "" {
            rawData["openingTime"] = self.openingTime
        }

        if self.closingTime != "00:00" &&
            self.closingTime != "" {
            rawData["closingTime"] = self.closingTime
        }

        rawData["partnerShop"] = self.showOnlyPartnerStore

        var selectedEquipments = [String]()
        for equipment in self.equipments {
            if equipment.isSelected {
                selectedEquipments.append(equipment.id)
            }
        }
        if selectedEquipments.count > 0 {
            rawData["amenities"] = selectedEquipments
        }

        var selectedDays = [String]()
        for day in self.businessDays {
            if day.isSelected {
                selectedDays.append(day.key)
            }
        }
        if selectedDays.count > 0 {
            rawData["days"] = selectedDays
        }

        if let lat = self.latitude {
            rawData["lat"] = lat
        }

        if let lon = self.longitude {
            rawData["lon"] = lon
        }

        if let radius = self.radius {
            rawData["radius"] = radius
        }

        return rawData
    }
}

extension Array where Element: NSCopying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            if let element = element.copy() as? Element {
                copiedArray.append(element)
            }
        }
        return copiedArray
    }
}
