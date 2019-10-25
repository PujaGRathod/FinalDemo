//
//  BasicInformationTableViewAdapter.swift
//  remone
//
//  Created by Akshit Zaveri on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol BasicInformationTableViewAdapterDelegate {
    func editButtonTapped(for section: BasicInformationTableViewAdapter.Section)
}

class BasicInformationTableViewAdapter: NSObject {

    private var tableView: UITableView!
    private var user: RMUser?
    var hideEdit: Bool = false

    struct Section {
        struct Row: Equatable {
            static func ==(lhs: BasicInformationTableViewAdapter.Section.Row, rhs: BasicInformationTableViewAdapter.Section.Row) -> Bool {
                return lhs.title == rhs.title && lhs.value == rhs.value
            }
            
            var index: Int?
            var title: String?
            var value: String?
        }
        
        var index: Int?
        var title: String?
        var rows: [Row] = []
    }
    
    private var items: [Section] = []
    var delegate: BasicInformationTableViewAdapterDelegate?

    init(with tableView: UITableView, delegate: BasicInformationTableViewAdapterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
        super.init()
        self.setupTableView()
    }
    
    func setupTableView() {
        let nib = UINib(nibName: "BasicInformationTableViewHeaderView", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "header")
        
        let nibCell = UINib(nibName: "BasicInformationTblCell", bundle: nil)
        self.tableView.register(nibCell, forCellReuseIdentifier: "cell")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.reloadData()
    }
    
    func loadUserProfile(for user: RMUser, _ completion: (()->Void)) {
        self.user = user
        var settings: [UserSettings: Bool] = [:]
        if self.hideEdit {
            settings = user.settings
        } else {
            for setting in user.settings {
                settings[setting.key] = true
            }
        }

        self.items = []
        if let section = self.createUserInfoSection(for: user, for: settings) {
            self.items.append(section)
        }

        if let section = self.createContactInfoSection(for: user, for: settings) {
            self.items.append(section)
        }

        if let section = self.createSkillsSection(for: user, for: settings) {
            self.items.append(section)
        }

        if let section = self.createGardnerLearingStyleSection(for: user) {
            self.items.append(section)
        }

        if let section = self.createHollandsInsightsSection(for: user) {
            self.items.append(section)
        }

        if let section = self.createPositiveAttributesSection(for: user) {
            self.items.append(section)
        }

        self.tableView.reloadData()
        completion()
    }

    func createPositiveAttributesSection(for user: RMUser) -> Section? {
        var section = Section()
        section.index = 5
        section.title = "Positive Attributes".localized
        section.rows = [Section.Row]()
        if let att = user.positiveAttributes {
            for (index, group) in att.groups.enumerated() {
                var row = Section.Row.init()
                row.index = index
                row.title = group.value
                section.rows.append(row)
            }
        }
        return section
    }

    func createHollandsInsightsSection(for user: RMUser) -> Section? {
        var section = Section()
        section.index = 4
        section.title = "Hollands Occupational Insights".localized
        section.rows = [Section.Row]()
        if let att = user.hollandInsights {
            for (index, group) in att.groups.enumerated() {
                var row = Section.Row.init()
                row.index = index
                row.title = group.value
                section.rows.append(row)
            }
        }
        return section
    }

    func createGardnerLearingStyleSection(for user: RMUser) -> Section? {
        var section = Section()
        section.index = 3
        section.title = "Howard Gardner’s Theory of Multiple Intelligences".localized
        section.rows = [Section.Row]()
        if let att = user.gardnerLearningStyle {
            for (index, group) in att.groups.enumerated() {
                var row = Section.Row.init()
                row.index = index
                row.title = group.value
                section.rows.append(row)
            }
        }
        return section
    }

    func createSkillsSection(for user: RMUser, for settings: [UserSettings: Bool]) -> Section? {
        var section = Section()
        section.index = 2
        section.title = "Skills".localized

        // Skills
        if settings[.disclosureInfo] == true,
            settings[.skill] == true {
            for (index, skill) in user.skills.enumerated() {
                var rowskill = Section.Row()
                rowskill.index = index
                rowskill.title = skill.name
                section.rows.append(rowskill)
            }
        } else {

        }
        return section
    }

    func createContactInfoSection(for user: RMUser, for settings: [UserSettings: Bool]) -> Section? {
        var section = Section()
        section.index = 1
        section.title = "Contact Info".localized

        // Email
        var rowEmail = Section.Row()
        rowEmail.index = 0
        rowEmail.title = "Email".localized
        if settings[.disclosureInfo] == true,
            settings[.email] == true {
            rowEmail.value = user.email
        } else {
            rowEmail.value = " - "
        }
        section.rows.append(rowEmail)

        // Mobile No
        var rowMobileNo = Section.Row()
        rowMobileNo.index = 1
        rowMobileNo.title = "Mobile No".localized
        rowMobileNo.value = user.mobileNo
        if settings[.disclosureInfo] == true,
            settings[.mobileNo] == true {
            rowMobileNo.value = user.mobileNo
        } else {
            rowMobileNo.value = " - "
        }
        section.rows.append(rowMobileNo)

        // Phone No
        var rowPhoneNo = Section.Row()
        rowPhoneNo.index = 2
        rowPhoneNo.title = "Phone No".localized
        rowPhoneNo.value = user.phoneNo
        if settings[.disclosureInfo] == true,
            settings[.phoneNo] == true {
            rowPhoneNo.value = user.phoneNo
        } else {
            rowPhoneNo.value = " - "
        }
        section.rows.append(rowPhoneNo)

        return section
    }

    func createUserInfoSection(for user: RMUser, for settings: [UserSettings: Bool]) -> Section? {
        var section = Section()
        section.index = 0
        section.title = "Basic Information".localized

        // Name
        var rowName = Section.Row()
        rowName.index = 0
        if settings[.disclosureInfo] == true,
           settings[.name] == true {
            rowName.value = user.name
        } else {
            rowName.value = " - "
        }
        rowName.title = "Name".localized
        section.rows.append(rowName)

//        //Ruby
//        var rowRugby = Section.Row()
//        rowRugby.index = 1
//        rowRugby.title = "Ruby".localized
//        if settings[.disclosureInfo] == true,
//           settings[.ruby] == true {
//            rowRugby.value = user.ruby
//        } else {
//            rowRugby.value = " - "
//        }
//        section.rows.append(rowRugby)

        // Title/Position
        var rowTitle = Section.Row()
        rowTitle.index = 2
        rowTitle.title = "Position".localized
        if settings[.disclosureInfo] == true,
           settings[.position] == true {
            rowTitle.value = user.position?.name
        } else {
            rowTitle.value = " - "
        }
        section.rows.append(rowTitle)

        //Department
        var rowDepartment = Section.Row()
        rowDepartment.index = 3
        rowDepartment.title = "Department".localized
        if settings[.disclosureInfo] == true,
           settings[.department] == true {
            rowDepartment.value = user.department?.name
        } else {
            rowDepartment.value = " - "
        }
        section.rows.append(rowDepartment)

        //Company
        var rowCompany = Section.Row()
        rowCompany.index = 4
        rowCompany.title = "Company".localized
        if settings[.disclosureInfo] == true,
            settings[.company] == true {
            rowCompany.value = user.company?.name
        } else {
            rowCompany.value = " - "
        }
        section.rows.append(rowCompany)

        // User Info
        var rowInfo = Section.Row()
        rowInfo.index = 5
        rowInfo.title = "Self Introduction".localized
        if settings[.disclosureInfo] == true {
        } else {
        }
        rowInfo.value = user.info
        section.rows.append(rowInfo)
        return section
    }

}

extension BasicInformationTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! BasicInformationTableViewHeaderView
        view.delegate = self
        view.set(section: self.items[section])
        if section == 0 {
            view.showTopLine(false)
        } else {
            view.showTopLine(true)
        }
        if section > 2 {
            view.hideEdit(true)
        } else {
            view.hideEdit(self.hideEdit)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionHeader = self.items[section]
        if let title = sectionHeader.title {
            let refWidth = tableView.frame.size.width - 78
            let height = title.height(withConstrainedWidth: refWidth, font: HiraginoSansW4(withSize: 20)) + 28
            if height < 49 {
                return 49
            } else {
                return height
            }
        }
        return 49
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 80
        case 1:
            return 36
        case 2:
            return 32
        default:
            return 36
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BasicInformationTblCell
        
        let section = self.items[indexPath.section]
        let row = section.rows[indexPath.item]
        cell.set(row: row)
        if row == section.rows.last {
            cell.shouldShowBottomSeparator(false)
        } else {
            cell.shouldShowBottomSeparator(true)
        }

        cell.makeTitleBold((indexPath.section >= 2))
        if indexPath.section > 2 {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 14)
        } else {
            cell.titleLabel.font = HiraginoSansW3(withSize: 14)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = self.items[indexPath.section]
//        let row = section.rows[indexPath.item]
//        if let valueText = row.value,
//            let titleText = row.title {
//            let refWidth = titleText.width(withConstrainedHeight: 16, font: HiraginoSansW3(withSize: 14)) - 40
//            let height = valueText.height(withConstrainedWidth: refWidth, font: HiraginoSansW3(withSize: 14)) + 28
//            return height
//        }
        return UITableViewAutomaticDimension
    }
}

extension BasicInformationTableViewAdapter: BasicInformationTableViewHeaderViewDelegate {
    
    func editButtonTapped(for section: BasicInformationTableViewAdapter.Section) {
        self.delegate?.editButtonTapped(for: section)
    }
}
