//
//  FavoriteOfficeListVC.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class FavoriteOfficeListVC: UITableViewController, FavoriteOfficeListAdapterDelegate {

    var adapter: FavoriteOfficeListAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter = FavoriteOfficeListAdapter.init(with: self.tableView, delegate: self)
        self.refreshControl?.addTarget(self.adapter, action: #selector(self.adapter.getOfficeList), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Favourite Office List")
        self.adapter.getOfficeList()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    func openOfficeProfile(_ office: RMOffice) {
        if office.locationType != .other {
            OfficeProfileVC.openOfficeProfile(for: office.id, on: self)
        }
    }

    func showAlert(with title: String, message: String) {
        self.showAlert(title, message: message)
    }

    func startedLoadingData() {
        self.refreshControl?.endRefreshing()
        self.showLoader()
    }

    func finishedLoadingData() {
        self.hideLoader()
    }

}
