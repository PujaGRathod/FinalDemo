//
//  OfficeSearchFilterBusinessDayAdapter.swift
//  remone
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol BusinessDayAdepterDelegate {

}

class OfficeSearchFilterBusinessDayAdapter: NSObject {

    private let tblFilterList: UITableView
    let delegate: BusinessDayAdepterDelegate
    var businessDays :[OfficeWorkingDays] = [OfficeWorkingDays]()

    init(with tableView: UITableView, withDelegate: BusinessDayAdepterDelegate, withDays: [OfficeWorkingDays]) {
        self.tblFilterList = tableView
        self.delegate = withDelegate
        self.businessDays = withDays
        super.init()
        self.setupTableView()
    }

    func setupTableView() {
        self.tblFilterList.delegate = self
        self.tblFilterList.dataSource = self
        self.tblFilterList.register(UINib.init(nibName: "FilterSelectionCell", bundle: nil), forCellReuseIdentifier: "FilterSelectionCell")
        self.tblFilterList.rowHeight = 44
    }

}

extension OfficeSearchFilterBusinessDayAdapter: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSelectionCell", for: indexPath) as! FilterSelectionCell
        let day = self.businessDays[indexPath.row]
        cell.lblTitle.text = day.name
        cell.viewTitleImage.isHidden = true
        cell.isSelectedFilter(day.isSelected)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let day = self.businessDays[indexPath.row]
        day.isSelected = !day.isSelected
        self.businessDays[indexPath.row] = day
        self.tblFilterList.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

}
