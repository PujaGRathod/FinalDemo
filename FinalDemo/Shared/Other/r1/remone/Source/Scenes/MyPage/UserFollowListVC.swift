
//
//  UserFollowListVC.swift
//  remone
//
//  Created by Arjav Lad on 24/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class UserFollowListVC: UITableViewController, OfficeUsersTblCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var reloadProfile: ((Int)->Void)?

    var followingList: [RMUser] = [RMUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "OfficeUsersTblCell", bundle: nil), forCellReuseIdentifier: "OfficeUsersTblCell")
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "My Following List")
        super.viewWillAppear(animated)
        self.getFollowingList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        self.reloadProfile?(self.followingList.count)
        self.navigationController?.popViewController(animated: true)
    }

    func getFollowingList() {
        self.showLoader()
        APIManager.shared.getFollowingUsers { (users, error) in
            self.hideLoader()
            self.followingList = users
            self.tableView.reloadData()
        }
    }

    func openProfile(at index: Int?) {
        if let index = index {
            let user: RMUser = self.followingList[index]
            UserProfileVC.loadUserProfile(for: user.id, on: self)
        }
    }

    func followUser(at index: Int?) {
        if let index = index {
            let officeUser: RMUser = self.followingList[index]
            func sendRequest() {
                self.showLoader()
                officeUser.followUnfollowUser { (success) in
                    self.hideLoader()
                    if success {
                        officeUser.followStatus = officeUser.followStatus.getNewStatus
                        self.followingList[index] = officeUser
                    }
                    self.tableView.reloadData()
                }
            }
            if officeUser.followStatus == .requested {
                self.showAlert("",
//                    "Follow request already sent".localized,
                               message: "Do you want to delete follow request?".localized,
                               actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                               cancelTitle: "no".localized,
                               actionHandler: { (action, _) in
                                sendRequest()
                },
                               cancelActionHandler: nil)
            }
            else if officeUser.followStatus == .following {
                self.showAlert("",
                               message: "Do you want to stop following?".localized,
                               actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                               cancelTitle: "no".localized,
                               actionHandler: { (action, _) in
                                sendRequest()
                },
                               cancelActionHandler: nil)
            }
            else {
                sendRequest()
            }
        }
    }

    func showMoreUsers() {

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeUsersTblCell", for: indexPath) as? OfficeUsersTblCell {
            let user = self.followingList[indexPath.row]
            cell.viewProfile.isHidden = false
            cell.btnShowMore.isHidden = true
            cell.loadProfile(for: user)
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = self.followingList[indexPath.row]
        UserProfileVC.loadUserProfile(for: user.id, on: self)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString.init(string: "no users found".localized, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                                             NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

}
