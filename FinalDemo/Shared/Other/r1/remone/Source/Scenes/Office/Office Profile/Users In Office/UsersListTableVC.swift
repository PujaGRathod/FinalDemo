//
//  UsersListTableVC.swift
//  remone
//
//  Created by Arjav Lad on 20/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class UsersListTableVC: UITableViewController, OfficeUsersTblCellDelegate {

    var users:[RMUser] = [RMUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "OfficeUsersTblCell", bundle: nil), forCellReuseIdentifier: "OfficeUsersTblCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Users in office")
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfficeUsersTblCell", for: indexPath) as! OfficeUsersTblCell
        let user = self.users[indexPath.row]
        cell.viewProfile.isHidden = false
        cell.btnShowMore.isHidden = true
        cell.loadProfile(for: user)
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = self.users[indexPath.row]
        self.openUserProfile(for: user)
    }

    func openUserProfile(for user: RMUser) {
        UserProfileVC.loadUserProfile(for: user.id, on: self)
    }
    
    func openProfile(at index: Int?) {
        if let index = index {
            let user: RMUser = self.users[index]
            UserProfileVC.loadUserProfile(for: user.id, on: self)
        }
    }

    func followUser(at index: Int?) {
        if let index = index {
            let officeUser: RMUser = self.users[index]
            func sendRequest() {
                self.showLoader()
                officeUser.followUnfollowUser { (success) in
                    self.hideLoader()
                    if success {
                        officeUser.followStatus = officeUser.followStatus.getNewStatus
                        self.users[index] = officeUser
                    }
                    self.tableView.reloadData()
                }
            }
            if officeUser.followStatus == .requested {
                self.showAlert("",
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
