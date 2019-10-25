//
//  UserTimelineVC.swift
//  remone
//
//  Created by Arjav Lad on 26/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class UserTimelineVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var barBtnInbox: UIBarButtonItem!
    
    var adapter: UserTimelineAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.tintColor = APP_COLOR_THEME
        // Do any additional setup after loading the view.
        self.adapter = UserTimelineAdapter.init(with: self.tblView, withDelegate: self)

        self.adapter.showAlert = { (title, message) in
            self.showAlert(title, message: message)
        }

//        self.showLoader()
//        self.adapter.loadTimeline(at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Home Timeline")
        super.viewWillAppear(animated)
        self.showLoader()
        self.adapter.reloadTimeline()
        self.reloadNotifications()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowTimestampDetailsVC" {
            if let detailsVC = segue.destination as? TimestampDetailsVC {
                detailsVC.timeStamp = sender as! RMTimestamp
                detailsVC.delegate = self
            }
        }
    }

    func reloadNotifications() {
        APIManager.shared.getUnreadCounts { (count) in
            if count != -1 {
                UIApplication.shared.applicationIconBadgeNumber = count
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            if count >= 0 {
                self.barBtnInbox.image = #imageLiteral(resourceName: "iconInboxUnread")
            } else {
                self.barBtnInbox.image = #imageLiteral(resourceName: "iconInbox")
            }
        }
    }
}

extension UserTimelineVC: UserTimelineAdapterDelegate {

    func dataLoadedInTableView(_ newDataFound: Bool) {
        self.hideLoader()
    }

    func comment(timestamp: RMTimestamp?) {
        if let timeStamp = timestamp {
            self.performSegue(withIdentifier: "segueShowTimestampDetailsVC", sender: timeStamp)
            print("Comment: \(String(describing: timestamp))")
        }
    }

    func showOption(timestamp: RMTimestamp?) {
        if let timeStamp = timestamp,
            let user = APIManager.shared.loginSession?.user {
            if user == timeStamp.user {
                self.showActionSheet(nil,
                                     message: nil,
                                     actionTitles:[("delete".localized, UIAlertActionStyle.destructive)],
                                     cancelTitle: "Cancel".localized,
                                     actionHandler: { (action, index) in
                                        if index == 0 {
                                            timeStamp.delete({ (success) in
                                                if success {
                                                    self.adapter.delete(timeStamp: timeStamp)
                                                }
                                            })
                                        }
                })
            } else {
                self.showActionSheet(nil,
                                     message: nil,
                                     actionTitles: [("Unfollow".localized, UIAlertActionStyle.destructive)],
                                     cancelTitle: "Cancel".localized,
                                     actionHandler: { (action, index) in
                                        self.showLoader()
                                        timeStamp.user.followUnfollowUser({ (success) in
                                            self.adapter.loadTimeline(at: 0)
                                        })
                })
            }
        }
    }

    func showLocation(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            if timestamp.company.locationType != .other {
                OfficeProfileVC.openOfficeProfile(for: timestamp.company.id, on: self)
            }
        }
    }

    func didSelect(timeStamp: RMTimestamp?) {
        if let timeStamp = timeStamp {
            self.performSegue(withIdentifier: "segueShowTimestampDetailsVC", sender: timeStamp)
        }
    }

    func showUserProfile(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            UserProfileVC.loadUserProfile(for: timestamp.user.id, on: self)
        }
    }

    func pullToRefresh() {
        self.reloadNotifications()
    }
}

extension UserTimelineVC: TimestampDetailsVCDelegate {
    func reload(timestamp: RMTimestamp) {
        self.adapter.refresh(with: timestamp)
    }

    func delete(timestamp: RMTimestamp) {
        self.adapter.delete(timeStamp: timestamp)
    }

    func refreshTimeline() {
        self.showLoader()
        self.adapter.loadTimeline(at: 0)
    }

}

