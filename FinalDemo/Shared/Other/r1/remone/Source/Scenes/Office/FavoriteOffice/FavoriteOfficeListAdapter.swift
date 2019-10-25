//
//  FavoriteOfficeListAdapter.swift
//  remone
//
//  Created by Arjav Lad on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol FavoriteOfficeListAdapterDelegate {
    func openOfficeProfile(_ office: RMOffice)
    func startedLoadingData()
    func finishedLoadingData()
    func showAlert(with title: String, message: String)
}

class FavoriteOfficeListAdapter: NSObject {
    let tblOfficeList: UITableView
    var officeList = [RMOffice]()
    let delegate: FavoriteOfficeListAdapterDelegate

    init(with tableView: UITableView, delegate: FavoriteOfficeListAdapterDelegate) {
        self.tblOfficeList = tableView
        self.delegate = delegate
        super.init()
        self.prepareTableView()
//        self.getOfficeList()
    }

    func prepareTableView() {
        self.tblOfficeList.delegate = self
        self.tblOfficeList.dataSource = self
        self.tblOfficeList.emptyDataSetSource = self
        self.tblOfficeList.emptyDataSetDelegate = self
        self.tblOfficeList.register(UINib.init(nibName: "FavoriteOfficeTblCell", bundle: nil), forCellReuseIdentifier: "FavoriteOfficeTblCell")
        self.tblOfficeList.rowHeight = 140
    }

    @objc func getOfficeList() {
        self.delegate.startedLoadingData()
        APIManager.shared.getFavoriteOffices { (offices, error) in
            self.delegate.finishedLoadingData()
            if let error = error {
                self.delegate.showAlert(with: "Error!".localized, message: error.localizedDescription)
                print("Error: \(error.localizedDescription)")
            } else {
                self.updateOfficeList(with: offices)
                print(offices)
            }
        }
    }

    func updateOfficeList(with newList: [RMOffice], append: Bool = false) {
        if !append {
            self.officeList = newList
        } else {
            let filteredList = newList.filter { (office) -> Bool in return !self.officeList.contains(office) }
            self.officeList.append(contentsOf: filteredList)
        }
        self.tblOfficeList.reloadData()
    }

}

extension FavoriteOfficeListAdapter: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.officeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteOfficeTblCell") as? FavoriteOfficeTblCell {
            cell.setup(for: officeList[indexPath.row])
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

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "no office found".localized, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                                             NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

}
