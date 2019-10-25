//
//  TimestampLikeListVC.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class TimestampLikeListVC: UIViewController, TimestampLikeTblCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    var timeStamp: RMTimestamp!
    var currentUser: RMUser? = APIManager.shared.loginSession?.user

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Timestamp Liked By List")

        self.tableView.register(UINib.init(nibName: "TimestampLikeTblCell", bundle: nil), forCellReuseIdentifier: "TimestampLikeTblCell")
        self.tableView.rowHeight = 57
        self.tableView.reloadData()
        self.tableView.allowsSelection = true
        self.getLikedByList()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    func getLikedByList() {
        self.timeStamp.getLikedBy { (users) in
            self.tableView.reloadData()
        }
    }

    func followUser(at index: Int?) {
        if let index = index {
            let user: RMUser = self.timeStamp.likedBy[index]
            func sendRequest() {
                self.showLoader()
                user.followUnfollowUser { (success) in
                    self.hideLoader()
                    user.followStatus = user.followStatus.getNewStatus
                    self.timeStamp.likedBy[index] = user
                    self.tableView.reloadData()
                }
            }
            if user.followStatus == .requested {
                self.showAlert("",
                               message: "Do you want to delete follow request?".localized,
                               actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                               cancelTitle: "no".localized,
                               actionHandler: { (action, _) in
                                sendRequest()
                }, cancelActionHandler: nil)
            } else if user.followStatus == .following {
                self.showAlert("",
                               message: "Do you want to stop following?".localized,
                               actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                               cancelTitle: "no".localized,
                               actionHandler: { (action, _) in
                                sendRequest()
                }, cancelActionHandler: nil)
            } else {
                sendRequest()
            }
        }
    }

}

extension TimestampLikeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeStamp.likedBy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TimestampLikeTblCell") as? TimestampLikeTblCell {
            let user = self.timeStamp.likedBy[indexPath.row]
            cell.loadUser(user)
            cell.delegate = self
            cell.index = indexPath.row
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = self.timeStamp.likedBy[indexPath.row]
        UserProfileVC.loadUserProfile(for: user.id, on: self)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

