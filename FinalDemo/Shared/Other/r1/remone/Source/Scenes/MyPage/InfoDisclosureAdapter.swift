//
//  infoDisclosureAdapter.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

protocol InfoDisclosureAdapterDelegate {
    
}

class InfoDisclosureAdapter: NSObject {

    var isAllowInfoDisclouse:Bool = true
    private let tblinfoDisclosureList: UITableView
    let delegate: InfoDisclosureAdapterDelegate
    var settings: [UserSettings: Bool] = [:]
    var items: [Section] = []
    
    struct Section {
        struct Row: Equatable {
            static func ==(lhs: InfoDisclosureAdapter.Section.Row, rhs: InfoDisclosureAdapter.Section.Row) -> Bool {
                return lhs.title == rhs.title && lhs.value == rhs.value
            }
            var index: Int?
            var title: String?
            var value: Bool = true
            let setting: UserSettings

            init(with setting: UserSettings) {
                self.setting = setting
            }
        }
        var index: Int?
        var title: String?
        var footerTitle : String?
        var rows: [Row] = []
    }
    
    
    func loadLocalData(_ completion: (()->Void)) {
        var section0 = Section()
        section0.index = 0
        section0.footerTitle = "If you have permission, you will be displayed in \"Search people\".".localized
        var row = Section.Row.init(with: .disclosureInfo)
        row.index = 0
        row.title = "Allow information disclosure".localized
        row.value = self.settings[.disclosureInfo] ?? true
        section0.rows.append(row)

        self.isAllowInfoDisclouse = self.settings[.disclosureInfo] ?? true

        let section1 = self.createUserInfoSection()
        let section2 = self.createContactInfoSection()
        let section3 = self.createSkillsSection()
        self.items = [section0, section1, section2,section3]

        self.tblinfoDisclosureList.reloadData()
        completion()
    }
    
    init(with tableView: UITableView, withDelegate: InfoDisclosureAdapterDelegate) {
        self.tblinfoDisclosureList = tableView
        self.delegate = withDelegate
        super.init()
        self.setupTableView()
    }
    
    func createSkillsSection() -> Section {
        var section = Section()
        section.index = 2
        section.title = ""

        var rowskill = Section.Row(with: .skill)
        rowskill.index = 0
        rowskill.title = "Skills".localized
        rowskill.value = self.settings[.skill] ?? true
        section.rows.append(rowskill)

        return section
    }

    func createContactInfoSection() -> Section {
        var section = Section()
        section.index = 1
        section.title = "Contact Info".localized

        // Email
        var rowEmail = Section.Row.init(with: .email)
        rowEmail.index = 0
        rowEmail.title = "Email".localized
        rowEmail.value = self.settings[.email] ?? true
        section.rows.append(rowEmail)

        // Mobile No
        var rowMobileNo = Section.Row.init(with: .mobileNo)
        rowMobileNo.index = 1
        rowMobileNo.title = "Mobile No".localized
        rowMobileNo.value = self.settings[.mobileNo] ?? true
        section.rows.append(rowMobileNo)

        // Phone No
        var rowPhoneNo = Section.Row.init(with: .phoneNo)
        rowPhoneNo.index = 2
        rowPhoneNo.title = "Phone No".localized
        rowPhoneNo.value = self.settings[.phoneNo] ?? true
        section.rows.append(rowPhoneNo)

        return section
    }

    func createUserInfoSection() -> Section {
        var section = Section()
        section.index = 0
        section.title = "Basic Information".localized

        // Name
        var rowName = Section.Row.init(with: .name)
        rowName.index = 0
        rowName.title = "Name".localized
        rowName.value = self.settings[.name] ?? true
        section.rows.append(rowName)

//        //Ruby
//        var rowRugby = Section.Row.init(with: .ruby)
//        rowRugby.index = 1
//        rowRugby.title = "Ruby".localized
//        rowRugby.value = self.settings[.ruby] ?? true
//        section.rows.append(rowRugby)

        // Title/Position
        var rowTitle = Section.Row.init(with: .position)
        rowTitle.index = 1
        rowTitle.title = "Position".localized
        rowTitle.value = self.settings[.position] ?? true
        section.rows.append(rowTitle)

        //Department
        var rowDepartment = Section.Row.init(with: .department)
        rowDepartment.index = 2
        rowDepartment.title = "Department".localized
        rowDepartment.value = self.settings[.department] ?? true
        section.rows.append(rowDepartment)

        //Company
        var rowCompany = Section.Row.init(with: .company)
        rowCompany.index = 3
        rowCompany.title = "Company".localized
        rowCompany.value = self.settings[.company] ?? true
        section.rows.append(rowCompany)

        return section
    }

    func setupTableView() {
        self.tblinfoDisclosureList.delegate = self
        self.tblinfoDisclosureList.dataSource = self
        self.tblinfoDisclosureList.register(UINib(nibName: "HeaderFooterCell", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "HeaderFooterCell")
        self.tblinfoDisclosureList.register(UINib.init(nibName: "LableSwitchTblCell", bundle: nil), forCellReuseIdentifier: "LableSwitchTblCell")
        self.tblinfoDisclosureList.estimatedRowHeight = 100
        self.tblinfoDisclosureList.rowHeight = UITableViewAutomaticDimension
        self.tblinfoDisclosureList.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tblinfoDisclosureList.estimatedSectionHeaderHeight = 100
        
    }

}

extension InfoDisclosureAdapter: LableSwitchTblCellDelegate {
    func updateSettings(for indexPath: IndexPath, value: Bool) {
        var setting = self.items[indexPath.section].rows[indexPath.row]
        setting.value = value
        if indexPath.section == 0 {
            self.isAllowInfoDisclouse = value
            for setting in self.settings {
                self.settings[setting.key] = value
            }
        } else {
            self.items[indexPath.section].rows[indexPath.row] = setting
            self.settings[setting.setting] = value
        }
        self.tblinfoDisclosureList.reloadData()
    }
}

extension InfoDisclosureAdapter: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isAllowInfoDisclouse {
            return self.items.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LableSwitchTblCell", for: indexPath) as!LableSwitchTblCell

        cell.delegate = self
        cell.indexPath = indexPath
        let item  = self.items[indexPath.section].rows[indexPath.row]
        cell.lblTitle.text = item.title
        cell.onOffSwitch.isOn = self.settings[item.setting] ?? true
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let viewHeader  = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderFooterCell")  as? HeaderFooterCell,
            section != 0 {
            let item = self.items[section]
            viewHeader.lblTitle.text = item.title
            viewHeader.lblFooter.text = ""
            return viewHeader
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0,
            let viewFooter  = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderFooterCell")  as? HeaderFooterCell {
            let item = self.items[section]
            viewFooter.lblFooter.text = item.footerTitle
            viewFooter.lblTitle.text = ""
            return viewFooter
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 52
        } else if section == 1 {
            return 24
        } else if section == 2 {
            return 0.001
        }
        return 32
    }
}
