
//
//  NotificationVC.swift
//  remone
//
//  Created by Arjav Lad on 29/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

enum followStatusString : String {
    case Accept = "ACCEPT"
    case Reject = "REJECT"
}

class NotificationVC: UIViewController {

    @IBOutlet weak var tblNotices: UITableView!
    @IBOutlet weak var segmentNotificationType: UISegmentedControl!

    var currentRequest: APIManager.APIRequest?
    private var paging: Pagination = Pagination()
    var isLoadingData: Bool = false

    private var refreshControl: UIRefreshControl = UIRefreshControl.init()
    var followersList: [RMFollowers] = []
    var notifications: [NotificationModel] = []

    var shouldOpenRequestTab: Bool = false
    
    var isNotificationSelected: Bool {
        if self.segmentNotificationType.selectedSegmentIndex == 0 {
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tblNotices.register(UINib.init(nibName: "NotificationTblCell", bundle: nil), forCellReuseIdentifier: "NotificationTblCell")
        self.tblNotices.register(UINib.init(nibName: "RequestTblCell", bundle: nil), forCellReuseIdentifier: "RequestTblCell")
        self.tblNotices.estimatedRowHeight = 84
        self.tblNotices.rowHeight = UITableViewAutomaticDimension
        self.tblNotices.emptyDataSetDelegate = self
        self.tblNotices.emptyDataSetSource = self
        self.setupRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldOpenRequestTab {
            self.segmentNotificationType.selectedSegmentIndex = 1
            self.shouldOpenRequestTab = false
        }
        self.reload()
    }

    func setupRefreshControl() {
        self.refreshControl.tintColor = APP_COLOR_THEME
        self.refreshControl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tblNotices.refreshControl = self.refreshControl
        } else {
            self.tblNotices.addSubview(self.refreshControl)
        }
    }

    @objc func reload() {
        self.refreshControl.endRefreshing()
        if !self.isNotificationSelected {
            Analytics.shared.trackScreen(name: "Follow Requests List")
            self.getPendingFollowersList()
        } else {
            Analytics.shared.trackScreen(name: "Notifications")
            self.getAllNotificaions(at: 0)
        }
    }
    
    func getPendingFollowersList()  {
        self.showLoader()
        APIManager.shared.getPendingFollowers { (result, error) in
            self.hideLoader()
            if let error = error {
                self.followersList = []
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.followersList = result
            }
            self.tblNotices.reloadData()
        }
    }

    func selectTab(notificationTab: Bool) {
        self.segmentNotificationType.selectedSegmentIndex = (notificationTab) ? 0 : 1
        self.isLoadingData = false
        self.currentRequest?.cancel()
        self.currentRequest = nil
        self.reload()
    }
    
    // TDOD: Add Pagination here, see timeline adapter for example
    func getAllNotificaions(at page: Int) {
        if self.isLoadingData ||
            self.currentRequest != nil {
            return;
//            self.currentRequest?.cancel()
//            self.isLoadingData = false
        }
        if  page != 0 &&
            self.paging.totalPages <= page {
            self.isLoadingData = false
            return;
        }
        self.isLoadingData = true
        self.showLoader()
        self.currentRequest =  APIManager.shared.getAllNotifications(at: page, { (models, error, pagination) in
            self.isLoadingData = false
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                if let page = pagination {
                    if page.currentPage == 0 {
                        self.notifications = models
                    } else {
                        let new = models.filter({ (mod) -> Bool in
                            return !(self.notifications.contains(mod))
                        })
                        self.notifications.append(contentsOf: new)
                    }
                    self.paging = page
                }
//                let count = self.notifications.filter({ return !$0.isRead}).count
//                UIApplication.shared.applicationIconBadgeNumber = count
            }
            self.currentRequest = nil
            self.tblNotices.reloadData()
        })
    }

    func markasRead(notification: NotificationModel) {
        APIManager.shared.markNotificationAsRead(notification: [notification]) { (error) in
            if let _ = error {

            } else {
                if let index = self.notifications.index(of: notification) {
                    var notification = self.notifications[index]
                    notification.isRead = true
                    self.notifications[index] = notification
                }
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    UIApplication.shared.applicationIconBadgeNumber -= 1
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                if self.isNotificationSelected {
                    self.tblNotices.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueTimestampDetails",
            let vc = segue.destination as? TimestampDetailsVC {
            vc.timeStamp = sender as! RMTimestamp
        }
    }

    @IBAction func onnotificationTypeChange(_ sender: UISegmentedControl) {
        if !self.isNotificationSelected {
            self.getPendingFollowersList()
        } else {
            self.getAllNotificaions(at: 0)
        }
    }

    func openNotification(_ notification: NotificationModel) {
        switch notification.type {
        case .post, .like, .comment:
            self.openPost(notification: notification)
        case .followRequest:
            self.selectTab(notificationTab: false)
        case .followRequestAccepted:
            UserProfileVC.loadUserProfile(for: notification.actionUserID, on: self)
        default:
            print("Unknown type")
        }
        self.markasRead(notification: notification)
    }
    
    private func openPost(notification: NotificationModel) {
        var request = APIManager.TimestampAPI.getTimestamp.request()
        if let id = notification.timestampId {
            request.id = id
            self.showLoader()
            APIManager.shared.getTimestampDetails(request: request, responseClosure: { (response) in
                self.hideLoader()
                if let timestamp = response.timestamp {
                    self.performSegue(withIdentifier: "segueTimestampDetails", sender: timestamp)
                }
            })
        } else {
            self.showAlert("Error".localized, message: "No data found!".localized)
        }
        
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource , DZNEmptyDataSetDelegate, DZNEmptyDataSetSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isNotificationSelected {
            return self.notifications.count
        } else {
            return self.followersList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isNotificationSelected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTblCell", for: indexPath) as? NotificationTblCell {
                let model = self.notifications[indexPath.row]
                cell.loadNotification(model)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestTblCell", for: indexPath) as? RequestTblCell {
                if self.followersList.count > indexPath.row {
                    let follower: RMFollowers = self.followersList[indexPath.row]
                    cell.index = indexPath.row
                    cell.lblName.text = follower.user.name
                    cell.delegate = self
                }
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(!isNotificationSelected) {
            let follower: RMFollowers =  self.followersList[indexPath.row]
            UserProfileVC.loadUserProfile(for: follower.user.id, on: self)
        } else {
            let model = self.notifications[indexPath.row]
            self.openNotification(model)
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text = ""
        if(!isNotificationSelected) {
            text = "no pending requests found".localized
        } else {
            text = "no notifications found".localized
        }
        let title = NSAttributedString.init(string: text, attributes: [NSAttributedStringKey.font: HiraginoSansW3(withSize: 14),
                                                                       NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        return title
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.isNotificationSelected {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

            // Change 10.0 to adjust the distance from bottom
            if maximumOffset - currentOffset <= 10.0 {
//            if let indexPath = self.tblNotices.indexPathForRow(at: contentOffset) {
//                if indexPath.row >= self.tblNotices.numberOfRows(inSection: indexPath.section) - 6 {
                    self.getAllNotificaions(at: self.paging.currentPage + 1)
//                }
            }
        }
    }
}

extension NotificationVC: RequestTblCellDelegate {
    func acceptedRequest(index: NSInteger){
        self.responseToRequest(at: index, with: .Accept)
    }

    func responseToRequest(at index: NSInteger, with status: followStatusString) {
        self.showLoader()
        let objFollower = self.followersList[index]
        let params = [
            "id": objFollower.id,
            "status": status.rawValue
            ] as [String : Any]
        APIManager.shared.acceptRejectFollowRequest(with: params) { (error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.followersList.remove(at: index)
                self.tblNotices.reloadData()
            }
        }
    }
    
    func rejectedRequest(index: NSInteger) {
        let objFollower = self.followersList[index]
        self.showActionSheet(nil,
                             message: nil,
                             actionTitles:[("Delete follow request".localized, UIAlertActionStyle.destructive)],
                             cancelTitle: "Cancel".localized,
                             actionHandler: { (action, index) in
                                if index == 0 {
                                    self.responseToRequest(at: index, with: .Reject)
                                }
        })
    }
}

