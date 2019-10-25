//
//  SearchPeopleTableViewsAdapter.swift
//  remone
//
//  Created by Inheritx on 31/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import MapKit
import DZNEmptyDataSet

protocol SearchPeopleTableViewsAdapterDelegate {
    func openUserProfile(_ user: RMUser)
    func loadingData()
    func dataLoadingFinished()
    func usersLoaded(_ users: [SearchPeopleModel])
    func openOfficeProfile(_ office: RMCompany)
    func showRattingsView()
}

enum SortingOptions {
    case name
    case position
    case status
    case distance
    case department
    case comapnyname
    case skill
    case covergence

    var title: String {
        switch self {
        case .name:
            return "By name".localized
        case .position:
            return "Position".localized
        case .status:
            return "By status".localized
        case .distance:
            return "Sort by distance".localized
        case .department:
            return "Affiliation order".localized
        case .comapnyname:
            return "By company name".localized
        case .skill:
            return "Skill sequence".localized
        case .covergence:
            return "Compatibility".localized
        }
    }
}

enum Sections: Int {
    case insideMap = 0
    case outsideMap = 1

    var title: String {
        switch self {
        case .insideMap:
            return "Members displayed on the map".localized

        case .outsideMap:
            return "Members not shown on the map".localized

        }
    }
}

class SearchPeopleTableViewsAdapter: NSObject, OfficeUsersTblCellDelegate {
    func showMoreUsers() {}
    var selectedOption: SortingOptions?

    private var selectedIndexPath: IndexPath?

    func followUser(at index: Int?) {}

    func openProfile(at index: Int?) {}

    private let tableView: UITableView
    private var userList: [Sections : [SearchPeopleModel]] = [:]
    let delegate: SearchPeopleTableViewsAdapterDelegate
    var allUsers: [SearchPeopleModel] {
        var users = [SearchPeopleModel]()
        for (_, value) in self.userList {
            users.append(contentsOf: value)
        }
        return users
    }

    init(with table: UITableView, delegate: SearchPeopleTableViewsAdapterDelegate) {
        self.tableView = table
        self.delegate = delegate
        super.init()
        self.setupTableView()
    }

    func setupTableView() {
        self.tableView.register(UINib.init(nibName: "SearchPeopleTblCell", bundle: nil), forCellReuseIdentifier: "SearchPeopleTblCell")
        self.tableView.register(UINib.init(nibName: "OfficeProfileSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "OfficeProfileSectionHeaderView")
        self.tableView.estimatedRowHeight = 56
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.reloadData()
    }

    func loadUsersList(_ users: [SearchPeopleModel], with option: SortingOptions) {
        self.selectedIndexPath = nil
        self.userList = [:]
        self.selectedOption = option
        self.separateModelType(for: users)
        self.sort(with: option)
//        self.tableView.reloadData()
    }

    private func separateModelType(for users: [SearchPeopleModel]) {
        self.userList = [.insideMap: [SearchPeopleModel](),
                         .outsideMap: [SearchPeopleModel]()]
        // Separate Users list
        let otherLocaitions = RMCompany.getOtherLocationList()
        for userModel in users {
            //            if userModel.user.isInHouseMember,//MARK: change of inhouse
            if userModel.user.shouldShowUser,
                let company = userModel.timestamp?.company,
                userModel.timestamp?.status != TimeStampStatus.workFinish,
                !otherLocaitions.contains(company),
                company.location != nil {
                self.userList[.insideMap]?.append(userModel)
            } else {
                self.userList[.outsideMap]?.append(userModel)
            }
        }
    }
    
    
    func clearList() {
        self.selectedOption = nil
        self.selectedIndexPath = nil
        self.userList = [:]
        self.tableView.reloadData()
    }

    private func sort(with option: SortingOptions) {
        switch option {
        case .name:
            self.sortWithName()
            break
        case .position:
            self.sortWithPosition()
            break
        case .status:
            self.sortWithStatus()
            break
        case .distance:
            self.sortWithDistance()
            break
        case .department:
            self.sortWithDepartment()
            break
        case .comapnyname:
            self.sortWithCompanyName()
            break
        case .skill:
            self.sortWithSkill()
            break
        case .covergence:
            self.sortWithConvergerence()
            break
        }
        self.tableView.reloadData()
    }

    private func sortWithName() {
        for (key, value) in self.userList {
            self.userList[key] = self.sortByName(value)
        }
        self.tableView.reloadData()
    }

    private func sortByName(_ list: [SearchPeopleModel]) -> [SearchPeopleModel] {
        return list.sorted(by: { (lhs, rhs) -> Bool in
            //            print("Comparing \(lhs.user.name) with \(rhs.user.name)")
            return lhs > rhs
        })
    }

    private func sortWithPosition() {
        for (key, value) in self.userList {
            self.userList[key] = value.sorted {
                if let postion1 = $0.user.position,
                    let position2 = $1.user.position {
                    return postion1.name.localizedCaseInsensitiveCompare(position2.name) == ComparisonResult.orderedAscending
                }
                return false
            }
        }
    }

    private func sortWithStatus() {
        for (key, value) in self.userList {
            self.userList[key] = value.sorted {
                let order1 = $0.timestamp?.status?.sortOrder ?? 10000
                let order2 = $1.timestamp?.status?.sortOrder ?? 10001
                return order1 < order2
            }
        }
        self.tableView.reloadData()
    }
    
    private func sortWithDistance(){
        if let currentUser = APIManager.shared.loginSession?.user,
            let currentLocation = currentUser.userLocation {
            let currentUserLocation = CLLocation(latitude: currentLocation.coordinates.latitude, longitude: currentLocation.coordinates.longitude)
            for (key, value) in self.userList {
                self.userList[key] = value.sorted {
                    var distanceFrom1: CLLocationDistance = 200000000
                    var distanceFrom2: CLLocationDistance = 200000000
                    if let location1 = $0.user.userLocation,
                        let location2 = $1.user.userLocation {
                        let userLocationCoordinate1 = CLLocation(latitude:location1.coordinates.latitude, longitude: location1.coordinates.longitude)
                        let userLocationCoordinate2 = CLLocation(latitude:location2.coordinates.latitude, longitude: location2.coordinates.longitude)
                        distanceFrom1 = currentUserLocation.distance(from: userLocationCoordinate1)
                        distanceFrom2 = currentUserLocation.distance(from:userLocationCoordinate2)
                    }
                    return distanceFrom1 < distanceFrom2
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func sortWithDepartment() {
        for (key, value) in self.userList {
            self.userList[key] = value.sorted {
                if let department1 = $0.user.department,
                    let department2 = $1.user.department {
                    return department1.name.localizedCaseInsensitiveCompare(department2.name) == ComparisonResult.orderedAscending
                }
                return false
            }
        }
        self.tableView.reloadData()
    }
    
    private func sortWithCompanyName() {
        for (key, value) in self.userList {
            self.userList[key] = value.sorted {
                if let company1 = $0.user.company,
                    let company2 = $1.user.company {
                    return company1.name.localizedCaseInsensitiveCompare(company2.name) == ComparisonResult.orderedAscending
                }
                return false
            }
        }
        self.tableView.reloadData()
    }

    private func sortWithSkill() {
        self.sort(with: .name)
    }

    private func sortWithConvergerence() {
        var list = [SearchPeopleModel]()
        for (_, value) in self.userList {
            list.append(contentsOf: value)
        }
        self.delegate.loadingData()
        APIManager.shared.matchDotinUser(with: list) { (newList) in
            self.separateModelType(for: newList)
            self.sortWithScore()
            self.delegate.dataLoadingFinished()
        }
    }

    private func sortWithScore() {
        for (key, value) in self.userList {
//            let filtered = value.filter({ (model) -> Bool in
//                return model.score >= 0.65
//            })
            self.userList[key] = value.sorted {
                return $0.score < $1.score
            }
        }
        self.tableView.reloadData()
    }

    func selectUser(_ userModel: SearchPeopleModel) {
        if let usersList = self.userList[.insideMap] {
            if let index = usersList.index(of: userModel) {
                let indexPath = IndexPath.init(row: index, section: 0)
                var indexes = [IndexPath]()
                if let oldIndex = self.selectedIndexPath {
                    indexes.append(oldIndex)
                }
                self.selectedIndexPath = indexPath
                indexes.append(indexPath)
                self.tableView.reloadRows(at: indexes, with: .automatic)
                if index < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }

}

extension SearchPeopleTableViewsAdapter: SearchPeopleTblCellDelegate {

    func showRattings(at index: IndexPath) {
        self.delegate.showRattingsView()
    }

    func openUserProfile(at index: IndexPath) {
        if let sectionKey = Sections.init(rawValue: index.section) {
            if let userModel = self.userList[sectionKey]?[index.row] {
                self.delegate.openUserProfile(userModel.user)
            }
        }
    }

    func openOfficeProfile(at index: IndexPath) {
        if let sectionKey = Sections.init(rawValue: index.section) {
            if let company = self.userList[sectionKey]?[index.row].timestamp?.company {
                self.delegate.openOfficeProfile(company)
            }
        }
    }
}

extension SearchPeopleTableViewsAdapter: UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userList.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionKey = Sections.init(rawValue: section) {
            return self.userList[sectionKey]?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPeopleTblCell") as?  SearchPeopleTblCell {
            if let section = Sections.init(rawValue: indexPath.section) {
                if let user = self.userList[section]?[indexPath.row] {
                    cell.loadProfile(for: user)
                    if let option = self.selectedOption,
                        option == .covergence {
                        cell.btnConvergenceRattings.isHidden = false
                        cell.btnConvergenceRattings.setTitle(user.ratting, for: .normal)
                    } else {
                        cell.btnConvergenceRattings.setTitle("", for: .normal)
                        cell.btnConvergenceRattings.isHidden = true
                    }
                    
                    cell.indexPath = indexPath
                    cell.delegate = self
                    if self.selectedIndexPath == indexPath {
                        cell.viewSelectionIndicator.isHidden = false
                    } else {
                        cell.viewSelectionIndicator.isHidden = true
                    }
                }
            }
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.openUserProfile(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionKey = Sections.init(rawValue: section) {
            if let value = self.userList[sectionKey],
                value.count <= 0 {
                return 0.001
            }
            return 32
        }
        return 0.0001
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionKey = Sections.init(rawValue: section) {
            if let value = self.userList[sectionKey],
               value.count <= 0 {
                return nil
            }
            return sectionKey.title
        }
        return nil
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "no users found".localized,
                                            attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                         NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }
}


