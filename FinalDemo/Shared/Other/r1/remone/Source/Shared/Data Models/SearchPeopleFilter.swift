//
//  SearchPeopleFilter.swift
//  remone
//
//  Created by Arjav Lad on 04/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

struct SearchPeopleModel: Equatable {

    var timestamp: RMTimestamp?
    let user: RMUser
    var score: Double = -1

    var ratting: String {
        if self.score >= 0.66 {
            return "★★★"
        } else if self.score < 0.65 &&
            self.score > 0.33 {
            return "★★"
        } else {
            return "★"
        }
    }

    init(with user: RMUser) {
        self.user = user
    }

    init(with user: RMUser, timeStamp: RMTimestamp?) {
        self.user = user
        self.timestamp = timeStamp
    }

    static func ==(lhs: SearchPeopleModel, rhs: SearchPeopleModel) -> Bool {
        return lhs.user.id == rhs.user.id
    }

    static func >(lhs: SearchPeopleModel, rhs: SearchPeopleModel) -> Bool {
        return lhs.user.name.localizedCaseInsensitiveCompare(rhs.user.name) == ComparisonResult.orderedAscending
    }

    static func <(lhs: SearchPeopleModel, rhs: SearchPeopleModel) -> Bool {
        return lhs.user.name.localizedCaseInsensitiveCompare(rhs.user.name) == ComparisonResult.orderedDescending
    }
}

class SearchPeopleFilter: NSObject {

    var showInHouseOnly: Bool = false
    var showTeamMembersOnly: Bool = false
    var showOnlyGoodAffinityPeople: Bool = false

    var searchKeyword: String = ""

    var status: [TimeStampStatus: Bool] = [:]

    var selectedStatus: TimeStampStatus? {
        for status in self.status {
            if status.value {
                return status.key
            }
        }
        return nil
    }

    var position: RMPosition?
    var department: RMDepartment?
    var company: RMCompany?
    var location: RMOffice?
    var skills: [RMSkill] = [RMSkill]()

    func displayText() -> String {
        var filterText: [String] = [String]()

        if self.showInHouseOnly {
            filterText.append("showInHouseOnly".localized)
        }

        if self.showTeamMembersOnly {
            filterText.append("showTeamMembersOnly".localized)
        }

        if self.showOnlyGoodAffinityPeople {
            filterText.append("Personal Match".localized)
        }

        if self.searchKeyword.count > 0 {
            filterText.append(self.searchKeyword)
        }

        if let selectedStatus = self.selectedStatus {
            filterText.append(selectedStatus.displayText)
        }

        if let position = self.position {
            filterText.append(position.name)
        }

        if let department = self.department {
            filterText.append(department.name)
        }

        if let company = self.company {
            filterText.append(company.name)
        }

        for skill in self.skills {
            filterText.append(skill.name)
        }

        if let place = self.location {
            filterText.append(place.name)
        }

        return filterText.joined(separator: ", ")

    }

    class func createFilter(with data: [String: Any]) -> SearchPeopleFilter {
        let filter = SearchPeopleFilter.generateDefaultFilter()

        filter.showInHouseOnly = data["inHouse"] as? Bool ?? false
        filter.showTeamMembersOnly = data["teamMember"] as? Bool ?? false
        filter.searchKeyword = data["name"] as? String ?? ""

        if let statusdata = data.stringValue(forkey: "userStatus") {
            for status in filter.status {
                if status.key.rawValue == statusdata {
                    filter.status[status.key] = true
                    break
                }
            }
        }

        filter.showOnlyGoodAffinityPeople = data["personalMatch"] as? Bool ?? false

        if let positionData = data["position"] as? [String: Any] {
             filter.position = RMPosition.init(with: positionData)
        }

        if let departmentData = data["department"] as? [String: Any] {
            filter.department = RMDepartment.init(with: departmentData)
        }

        if let companyData = data["company"] as? [String: Any] {
            filter.company = RMCompany.init(with: companyData)
        }

        if let locationData = data["location"] as? [String: Any] {
            filter.location = RMOffice.init(with: locationData)
        }

        filter.skills = [RMSkill]()
        if let skillsData = data["skills"] as? [[String: Any]] {
            for skillData in skillsData {
                if let skill = RMSkill.init(with: skillData) {
                    filter.skills.append(skill)
                }
            }
        }

        return filter

    }

    class func generateDefaultFilter() -> SearchPeopleFilter {
        let filter = SearchPeopleFilter()

        filter.status = [TimeStampStatus.available: false,
                         TimeStampStatus.busy: false,
                         TimeStampStatus.away: false,
                         TimeStampStatus.workFinish: false
        ]

        return filter
    }

    func isActive() -> Bool {
        if self.showTeamMembersOnly ||
            self.showInHouseOnly ||
            self.showOnlyGoodAffinityPeople {
            return true
        }

        if self.searchKeyword.trimString().count > 0 {
            return true
        }

        if let _ = self.selectedStatus {
            return true
        }

        if self.position != nil ||
            self.department != nil ||
            self.company != nil ||
            self.location != nil ||
            self.skills.count > 0 {
            return true
        }

        return false
    }

    func otherFilterApplied() -> Bool {
        if self.showTeamMembersOnly ||
            self.showInHouseOnly {
            return true
        }

        if self.searchKeyword.trimString().count > 0 {
            return true
        }

        if let _ = self.selectedStatus {
            return true
        }

        if self.position != nil ||
            self.department != nil ||
            self.company != nil ||
            self.location != nil ||
            self.skills.count > 0 {
            return true
        }

        return false
    }


}
