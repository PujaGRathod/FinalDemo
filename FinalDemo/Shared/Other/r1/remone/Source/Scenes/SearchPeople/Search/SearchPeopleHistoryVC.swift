//
//  SearchPeopleHistory.swift
//  remone
//
//  Created by Arjav Lad on 06/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class SearchPeopleHistoryVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var btnClose: UIBarButtonItem!

    var historyList: [SearchPeopleFilter] = [SearchPeopleFilter]()
    var selectedHistory: SearchPeopleFilter?
    var closure: SearchPeopleFilterClosure? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.shared.trackScreen(name: "Search People History")
        self.clearsSelectionOnViewWillAppear = true
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        self.tableView.estimatedRowHeight = 57
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self

        self.showLoader()
        APIManager.shared.getSearchPeopleHistory { (list, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.historyList = list
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCloseTap(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.closure?(self.selectedHistory)
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let cellDeq = tableView.dequeueReusableCell(withIdentifier: "OfficeSearchHistoryTblCell") {
            cell = cellDeq
        } else {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "OfficeSearchHistoryTblCell")
        }
        let history = self.historyList[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = history.displayText()
        cell.textLabel?.font =  HiraginoSansW3(withSize: 12)  //PingFangSCRegular(withSize: 12)
        cell.textLabel?.textColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
        cell.selectionStyle = .none
        cell.tintColor = APP_COLOR_THEME
        if self.selectedHistory == history {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "No history found.".localized, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                                                NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let history = self.historyList[indexPath.row]
        if self.selectedHistory == history {
            self.selectedHistory = nil
        } else {
            self.selectedHistory = history
        }
        tableView.reloadData()
    }

}
