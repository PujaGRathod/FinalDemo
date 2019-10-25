//
//  OfficeSearchListAdapter.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol OfficeSearchListAdapterDelegate {
    func openOfficeProfile(_ office: RMOffice)
}

class OfficeSearchListAdapter: NSObject {

    let tblList: UITableView
    var officeList = [RMOffice]()
    let delegate: OfficeSearchListAdapterDelegate

    init(with table: UITableView, delegate: OfficeSearchListAdapterDelegate) {
        self.tblList = table
        self.delegate = delegate
        super.init()
        self.prepareTableView()
    }

    func prepareTableView() {
        self.tblList.delegate = self
        self.tblList.dataSource = self
        self.tblList.emptyDataSetDelegate = self
        self.tblList.emptyDataSetSource = self
        self.tblList.register(UINib.init(nibName: "OfficeSearchListTblCell", bundle: nil), forCellReuseIdentifier: "OfficeSearchListTblCell")
        self.tblList.rowHeight = 140
    }

    func calculateTableHeight() -> CGFloat {
        let count = self.officeList.count
        let totalHeight = CGFloat(count * 140)
        if totalHeight == 0 ||
            totalHeight >= 290 {
            return 290
        } else {
            return totalHeight
        }
    }

    func updateOfficeList(with newList: [RMOffice], append: Bool = false) {
        if !append {
            self.officeList = newList
        } else {
            let filteredList = newList.filter { (office) -> Bool in return !self.officeList.contains(office) }
            self.officeList.append(contentsOf: filteredList)
        }
        self.tblList.reloadData()
    }

}

extension OfficeSearchListAdapter: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.officeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeSearchListTblCell") as? OfficeSearchListTblCell {
            let office = self.officeList[indexPath.row]
            cell.setup(for: office)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let office = self.officeList[indexPath.row]
        self.delegate.openOfficeProfile(office)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "no office found".localized, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                                             NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }
}

