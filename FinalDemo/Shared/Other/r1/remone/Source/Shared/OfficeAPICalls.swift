//
//  OfficeAPICalls.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Alamofire
import GooglePlaces

// MARK: - Office Search
extension APIManager {

    func sortCompanyWithDistance(list: [RMCompany]) -> [RMCompany] {
        if let currentUser = APIManager.shared.loginSession?.user,
            let currentLocation = currentUser.userLocation {
            let currentUserLocation = CLLocation(latitude: currentLocation.coordinates.latitude, longitude: currentLocation.coordinates.longitude)
            let companyListSorted = list.sorted {
                var distanceFrom1: CLLocationDistance = 200000000000
                var distanceFrom2: CLLocationDistance = 200000000000
                if let location1 = $0.location,
                    let location2 = $1.location {
                    let userLocationCoordinate1 = CLLocation(latitude:location1.latitude, longitude: location1.longitude)
                    let userLocationCoordinate2 = CLLocation(latitude:location2.latitude, longitude: location2.longitude)
                    distanceFrom1 = currentUserLocation.distance(from: userLocationCoordinate1)
                    distanceFrom2 = currentUserLocation.distance(from:userLocationCoordinate2)
                }
                return distanceFrom1 < distanceFrom2
            }
            return companyListSorted
        }
        return list
    }

    func sortOfficeWithDistance(from location: CLLocationCoordinate2D?, list: [RMOffice]) -> [RMOffice] {
        func sort(companyList: [RMOffice], from loc: CLLocationCoordinate2D) -> [RMOffice] {
            let refLocation = CLLocation.init(latitude: loc.latitude, longitude: loc.longitude)
            let companyListSorted = list.sorted {
                let location1 = $0.location.coordinates
                let location2 = $1.location.coordinates
                let userLocationCoordinate1 = CLLocation(latitude:location1.latitude, longitude: location1.longitude)
                let userLocationCoordinate2 = CLLocation(latitude:location2.latitude, longitude: location2.longitude)
                let distanceFrom1 = refLocation.distance(from: userLocationCoordinate1)
                let distanceFrom2 = refLocation.distance(from:userLocationCoordinate2)
                return distanceFrom1 < distanceFrom2
            }
            return companyListSorted
        }
        if let location = location {
            return  sort(companyList: list, from: location)
        } else if let currentUser = APIManager.shared.loginSession?.user,
            let currentLocation = currentUser.userLocation?.coordinates {
            return sort(companyList: list, from: currentLocation)
        }
        return list
    }

    func searchCompany(with filter: OfficeSearchFilter, _ completion: @escaping ([RMOffice], Error?) -> Void) -> APIRequest? {

        func complete(result: [RMOffice], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var param: [String: Any] = [:]
        for (filterKey, filterValue) in filter.getRawData() {
            param[filterKey] = filterValue
        }
        return self.makePOSTRequest(with: "company/search", parameters: param, { (response) in
            var offices = [RMOffice]()
            if let error = response.error {
                complete(result: offices, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let office = RMOffice.init(with: data),
                        office.locationType != .other {
                        if office.deleted == false {
                            if offices.contains(office) {
                                print("Duplicate office: \(office.id)")
                            } else {
                                offices.append(office)
                            }
                        } else {
                            print("Office deleted: \(office.id) - \(office.name)")
                        }
                    }
                }
//                offices = self.sortOfficeWithDistance(list: offices)
                complete(result: offices, error: nil)
            } else {
                complete(result: offices, error: NSError.error(with: "Unknown error!".localized))
            }
        })
    }

    func getOfficeNearMe(_ completion: @escaping ([RMOffice], Error?) -> Void) -> APIRequest? {
        func complete(result: [RMOffice], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        return self.makeGETRequest(with: "company/searchNearMe") { (response) in
            var offices = [RMOffice]()
            if let error = response.error {
                complete(result: offices, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let office = RMOffice.init(with: data),
                        office.locationType != .other,
                        office.deleted == false {
                        offices.append(office)
                    }
                }
//                offices = self.sortOfficeWithDistance(list: offices)
                complete(result: offices, error: nil)
            } else {
                complete(result: offices, error: NSError.error(with: "Unknown error!".localized))
            }
        }
    }

    func getOfficeSearchHistory(_ completion: @escaping ([OfficeSearchHistory], Error?) -> Void) {
        func complete(result: [OfficeSearchHistory], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        _ = self.makeGETRequest(with: "company/search/history") { (response) in
            var historyList = [OfficeSearchHistory]()
            if let error = response.error {
                complete(result: historyList, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let history = OfficeSearchHistory.init(with: data) {
                        historyList.append(history)
                    }
                }
                complete(result: historyList, error: nil)
            } else {
                complete(result: historyList, error: NSError.error(with: "Unknown error!".localized))
            }
        }
    }

    func getAllAmenities(_ completion: @escaping ([OfficeEquipment], Error?) -> Void) {
        func complete(result: [OfficeEquipment], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        _ = self.makeGETRequest(with: "amenity/all") { (response) in
            var equipmentList = [OfficeEquipment]()
            if let error = response.error {
                complete(result: equipmentList, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let equipment = OfficeEquipment.init(with: data) {
                        equipmentList.append(equipment)
                    }
                }
                complete(result: equipmentList, error: nil)
            } else {
                complete(result: equipmentList, error: NSError.error(with: "Unknown error!".localized))
            }
        }
    }

    func markAsFavorite(officeID: String, _ completion: @escaping (Error?) -> Void) {
        _ = self.makeGETRequest(with: "user/markfavoffice/\(officeID)") { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(error)
                } else if let _ = response.result {
                    completion(nil)
                } else {
                    completion(NSError.error(with: "Unknown error!".localized))
                }
            }
        }
    }

    func getFavoriteOffices(_ completion: @escaping ([RMOffice], Error?) -> Void) {
        func complete(result: [RMOffice], error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }
        _ = self.makeGETRequest(with: "user/favoffices") { (response) in
            var offices = [RMOffice]()
            if let error = response.error {
                complete(result: offices, error: error)
            } else if let result = response.result?["data"] as? [[String: Any]] {
                for data in result {
                    if let data = data["company"] as? [String: Any] {
                        if let office = RMOffice.init(with: data),
                            office.locationType != .other,
                            office.deleted == false {
                            offices.append(office)
                        }
                    }
                }
                complete(result: offices, error: nil)
            } else {
                complete(result: offices, error: NSError.error(with: "Unknown error!".localized))
            }
        }
    }
}

// MARK: - Office Profile
extension APIManager {
    func getCompanyProfile(for companyid: String, _ completion: @escaping (RMOffice?, Error?)->Void) {
        _ = self.makeGETRequest(with: "company/\(companyid)/detail") { (response) in
            DispatchQueue.main.async {
                if let error = response.error {
                    completion(nil, error)
                } else if let data = response.result {
                    if let office = RMOffice.init(with: data),
                        office.locationType != .other,
                        !office.deleted {
                        completion(office, nil)
                    } else {
                        completion(nil, nil)
                        //                        completion(nil, NSError.error(with: "Unknown error!".localized))
                    }
                } else {
                    completion(nil, NSError.error(with: "Unknown error!".localized))
                }
            }
        }
    }
}
