
//
//  TimestampDetailsVC.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol TimestampDetailsVCDelegate {
    func reload(timestamp: RMTimestamp)
    func delete(timestamp: RMTimestamp)
    func refreshTimeline()
}

class TimestampDetailsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var viewAddComment: UIView!

    var timeStamp: RMTimestamp!
    var comments: [RMTimestampComment] = [RMTimestampComment]()
    var delegate: TimestampDetailsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Timestamp Comments")

        self.tblView.delegate = self
        self.tblView.dataSource = self

        self.txtComment.add(padding: 16, viewMode: .leftSide)
        self.txtComment.layer.cornerRadius = 16
        self.txtComment.clipsToBounds = true
        self.txtComment.layer.borderWidth = 1
        self.txtComment.delegate = self
        let color = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.txtComment.layer.borderColor = color.cgColor

        self.tblView.register(UINib.init(nibName: "TimstampDetailsTblCell", bundle: nil), forCellReuseIdentifier: "TimstampDetailsTblCell")
        self.tblView.register(UINib.init(nibName: "TimestampCommentTblCell", bundle: nil), forCellReuseIdentifier: "TimestampCommentTblCell")
        self.tblView.estimatedRowHeight = 200
        self.tblView.rowHeight = UITableViewAutomaticDimension
        self.tblView.allowsSelection = false
        self.txtComment.text = ""
        self.fetchComments()
        self.confirmTimeStamp()
//        self.updateCounts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Cancel".localized
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localized
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowTimestampLikeListVC" {
            if let likeDetailVC = segue.destination as? TimestampLikeListVC {
                likeDetailVC.timeStamp = sender as! RMTimestamp
            }
        }
    }

    func fetchComments() {
        self.showLoader()
        APIManager.shared.getComments(for: self.timeStamp.id) { (commentsALL, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.comments = commentsALL
                self.tblView.reloadData()
                self.scrollToLastRow()
            }
        }
    }

    func scrollToLastRow() {
        let index = self.comments.count - 1
        if index >= 0 {
            let indexPath = IndexPath.init(row: index, section: 1)
            if index < self.tblView.numberOfRows(inSection: 1) {
                self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func postComment(with text: String) {
        self.showLoader()
        APIManager.shared.addComment(text, for: self.timeStamp.id, completion: { (error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            }
            if let status = self.timeStamp.status {
                Analytics.shared.trackTimestampComment(with: status)
            }
            self.timeStamp.increaseCommentCount(by: 1)
            self.delegate?.reload(timestamp: self.timeStamp)
            self.tblView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
            self.fetchComments()
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let commentText = textField.text?.trimString(),
            !commentText.isEmpty,
            commentText != "" {
            self.postComment(with: commentText)
            textField.text = ""
            textField.resignFirstResponder()
        } else {
            textField.text = ""
            textField.resignFirstResponder()
        }
        return true
    }

    func confirmTimeStamp() {
        if !self.timeStamp.isConfirmed &&
            self.timeStamp.user.isFromSameTeam &&
            RMUser.isCurrentRoleManager() {
            APIManager.shared.confirmTimeStamp(self.timeStamp, {
                self.timeStamp.isConfirmed = true
                self.delegate?.reload(timestamp: self.timeStamp)
                self.tblView.reloadData()
            })
        }
    }

}

extension TimestampDetailsVC: TimstampDetailsTblCellDelegate {
    func like(timestamp: RMTimestamp?) {
        if let timeStamp = timestamp {
            timeStamp.updateLikeStatus {
                self.delegate?.reload(timestamp: self.timeStamp)
                self.tblView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
            }
        }
    }

    func comment(timestamp: RMTimestamp?) {
        self.txtComment.becomeFirstResponder()
    }

    func showOption(timestamp: RMTimestamp?) {
        if let user = APIManager.shared.loginSession?.user,
            let timestamp = timestamp {
            if user == timestamp.user {
                self.showActionSheet(nil,
                                     message: nil,
                                     actionTitles: [("delete".localized, UIAlertActionStyle.destructive)],
                                     cancelTitle: "cancel".localized,
                                     actionHandler: { (action, index) in
                                        self.timeStamp.delete({ (success) in
                                            self.delegate?.delete(timestamp: self.timeStamp)
                                            if success {
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        })
                })
            } else {
                self.showActionSheet(nil,
                                     message: nil,
                                     actionTitles: [("Unfollow".localized, UIAlertActionStyle.destructive)],
                                     cancelTitle: "cancel".localized,
                                     actionHandler: { (action, index) in

                                        self.showLoader()
                                        timestamp.user.followUnfollowUser({ (success) in
                                            self.hideLoader()
                                            self.delegate?.refreshTimeline()
                                            self.navigationController?.popViewController(animated: true)
                                        })
                })
            }
        }
    }

    func showLocation(for id: String) {
        OfficeProfileVC.openOfficeProfile(for: id, on: self)
    }

    func showLocation(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            if timestamp.company.locationType != .other {
                OfficeProfileVC.openOfficeProfile(for: timestamp.company.id, on: self)
            }
        }
    }

    func showLikeDetails(timestamp: RMTimestamp?) {
        self.performSegue(withIdentifier: "segueShowTimestampLikeListVC", sender: self.timeStamp)
    }

    func showUserProfile(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            UserProfileVC.loadUserProfile(for: timestamp.user.id, on: self)
        }
    }

}

extension TimestampDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TimstampDetailsTblCell", for: indexPath) as? TimstampDetailsTblCell {
                cell.delegate = self
                cell.setup(for: self.timeStamp)
                return cell
            }
            return UITableViewCell()
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TimestampCommentTblCell", for: indexPath) as? TimestampCommentTblCell {
                let comment = self.comments[indexPath.row]
                cell.setup(for: comment)
                cell.showLocation = { (comment) in
                    if let company = comment?.userTimeStamp?.company {
                        if company.locationType != .other {
                            self.showLocation(for: company.id)
                        }
                    }
                }

                cell.showUserProfile = { comment in
                    if let comment = comment {
                        UserProfileVC.loadUserProfile(for: comment.user.id, on: self)
                    }
                }
                return cell
            }
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 0.001
    }

}
