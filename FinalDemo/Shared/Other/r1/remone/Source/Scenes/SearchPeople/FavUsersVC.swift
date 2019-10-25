//
//  FavUsersVC.swift
//  remone
//
//  Created by Arjav Lad on 03/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FavUsersVC: UITableViewController, SearchPeopleTblCellDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var users:[SearchPeopleModel] = [SearchPeopleModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .white
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.refreshControl?.tintColor = APP_COLOR_THEME
        self.refreshControl?.addTarget(self, action: #selector(self.loadFavUsers), for: .valueChanged)
        self.tableView.register(UINib.init(nibName: "SearchPeopleTblCell", bundle: nil), forCellReuseIdentifier: "SearchPeopleTblCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Favourite People")
        super.viewWillAppear(animated)
        self.loadFavUsers()
    }

    @objc func loadFavUsers() {
        self.refreshControl?.endRefreshing()
        self.showLoader()
        APIManager.shared.getFavUsers { (usersList, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.users = usersList
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPeopleTblCell", for: indexPath) as! SearchPeopleTblCell

        let usermodel = self.users[indexPath.row]
        cell.loadProfile(for: usermodel)
        cell.btnConvergenceRattings.isHidden = true
        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.openUserProfile(at: indexPath)
    }

    func openOfficeProfile(at index: IndexPath) {
        if let timeStampCompany = self.users[index.row].timestamp?.company {
            if timeStampCompany.locationType != .other {
                OfficeProfileVC.openOfficeProfile(for: timeStampCompany.id, on: self)
            }
        }
    }

    func showRattings(at index: IndexPath) {

    }

    func openUserProfile(at index: IndexPath) {
        let user = self.users[index.row].user
        UserProfileVC.loadUserProfile(for: user.id, on: self)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "no users found".localized, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                                             NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
