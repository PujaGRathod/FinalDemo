//
//  UserProfileTableVC.swift
//  remone
//
//  Created by Akshit Zaveri on 09/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

typealias UserProfileReload = () -> Void

class UserProfileTableVC: TwitterProfileViewController, RMUserInfoViewDelegate {

    enum RMUserProfileSection {
        case timeline
        case basicInformation
    }
    
    @IBOutlet var viewBackground: UIView!
    //
    private var kvoContextMainTableView: UInt8 = 1
    private var kvoContextTimelineTableView: UInt8 = 2
    private var kvoContextBasicInfoTableView: UInt8 = 3
    
    // Table header
    @IBOutlet private var headerView: UIView!
    @IBOutlet private weak var coverImageView: RMUserCoverImageView!
    @IBOutlet private weak var userProfileImageView: RMUserProfileImageView!
    @IBOutlet private weak var userInfoView: RMUserInfoView!
    
    // Section header
    @IBOutlet private weak var selectedSectionIndicatorView: UIView?
    @IBOutlet private weak var timelineSectionButton: UIButton?
    @IBOutlet private weak var basicInformationSectionButton: UIButton?
    @IBOutlet private weak var selectedSectionIndicatorLeadingConstraint: NSLayoutConstraint?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var tableViewsParentView: UIStackView!
    @IBOutlet private var timelineTableView: UITableView!
    @IBOutlet private var basicInformationTableView: UITableView!
    
    @IBOutlet private var headerViewTest: UIView!
    
    private var selectedSection: RMUserProfileSection?
    private var timelineAdapter: UserTimelineAdapter?
    private var basicInformationTableViewAdapter: BasicInformationTableViewAdapter?

    var user: RMUser!
    var userID: String?

    var isCurrentUser: Bool {
        if self.userID == APIManager.shared.loginSession?.user.id {
            return true
        }
        return false
    }

    class func loadUserProfile(for id: String, on vc: UIViewController) {
        let story = UIStoryboard.init(name: "UserProfile", bundle: nil)
        if let navProfile = story.instantiateViewController(withIdentifier: "navUserProfile") as? UINavigationController {
            if let profileVC = navProfile.viewControllers.first as? UserProfileTableVC {
                profileVC.userID = id
                profileVC.addbackButton()
                vc.present(navProfile, animated: true, completion: {

                })
            }
        }
    }

    @IBAction func onSettingsTap(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueShowMyPageSetting", sender: nil)
    }

    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func addbackButton() {
        let backBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backBtn.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backBtn
    }

    func openOfficeProfile(for id: String) {
        OfficeProfileVC.openOfficeProfile(for: id, on: self)
    }

    func loadUserProfile(_ showLoader: Bool = true) {
        self.showLoader()
        func reloadUI() {
            if self.isCurrentUser {
                self.userInfoView.isFromTeam(false)
                self.setCurrentUserDetails()
                self.basicInformationTableViewAdapter?.hideEdit = false
                let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
                self.navigationItem.rightBarButtonItem = btnSettings
            } else {
                self.userProfileImageView.set(url: self.user.profilePicture)
                self.coverImageView.set(url: self.user.coverPicture)
                self.navigationItem.rightBarButtonItem = nil
                self.basicInformationTableViewAdapter?.hideEdit = true
            }

            self.basicInformationTableViewAdapter?.loadUserProfile(for: self.user) {
                self.hideLoader()
            }
            self.timelineAdapter?.reloadTimeline()
            self.getLatestTimeStamp()
        }
        
        func noUserFound() {
            self.hideLoader()
            if !self.isCurrentUser {
                self.showAlert("Error!", message: "Data not found!".localized, actionHandler: { (_) in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            } else {
                self.showAlert("Error!", message: "Data not found!".localized, actionHandler: { (_) in
                    APIManager.shared.loginSession?.logout()
                    RMLoginSession.setupLogoutFlow()
                })
            }
        }

        if let id = self.userID {
            APIManager.shared.getUserProfile(for: id) { (fetchedUser, error) in
                if let fetchedUser = fetchedUser {
                    self.user = fetchedUser
                    reloadUI()
                } else {
                    noUserFound()
                }
            }
        } else {
            self.user = APIManager.shared.loginSession?.user
            self.userID = self.user.id
            APIManager.shared.getUserProfile(for: self.user.id) { (fetchedUser, error) in
                if let fetchedUser = fetchedUser {
                    self.user = fetchedUser
                    APIManager.shared.loginSession?.user = fetchedUser
                    APIManager.shared.loginSession?.save()
                    reloadUI()
                } else if let error = error {
                    self.hideLoader()
                    self.showAlert("Error!", message: error.localizedDescription, actionHandler: { (_) in

                    })
                } else {
                    noUserFound()
                }
            }
        }
    }

    func getLatestTimeStamp() {
        self.showLoader()
        if let id = self.userID {
            _ = APIManager.shared.getTimeline(for: id, at: 0, size: 1) { (timeStamps, error, pagination) in
                self.hideLoader()
                let timestamp = timeStamps.first
                if let ts = timestamp,
                    let user = APIManager.shared.loginSession?.user {
                    self.userInfoView.set(timestamp: ts, user: user)
                    self.userInfoView.delegate = self
                }
            }
        }
    }
    
    private func setCurrentUserDetails() {
        if let user = APIManager.shared.loginSession?.user {
            self.userProfileImageView.set(url: user.profilePicture)
            self.coverImageView.set(url: user.coverPicture)
        }
    }

    
//    // MARK: Twitter like UI methods
//    override func numberOfSegments() -> Int {
//        return 2
//    }
//
//    override func segmentTitle(forSegment index: Int) -> String {
//        return "Segment \(index)"
//    }
//
//    override func prepareForLayout() {
//        super.prepareForLayout()
//    }
//
//    override func scrollView(forSegment index: Int) -> UIScrollView {
//        switch index {
//        case 0:
//            return self.timelineTableView
//        default:
//            return self.basicInformationTableView
//        }
//    }
    // MARK: ----------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
//        self.tableView.setTableHeaderView(headerView: self.headerView)

        self.basicInformationTableViewAdapter = BasicInformationTableViewAdapter.init(with: self.basicInformationTableView, delegate: self)
        if self.timelineAdapter == nil {
            self.timelineAdapter = UserTimelineAdapter(with: self.timelineTableView, withDelegate: self)
        }
        //self.timelineAdapter?.removeRefreshControll()
        if self.tabBarController != nil {
            let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
            self.navigationItem.rightBarButtonItem = btnSettings
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadUserProfile()
        self.setCurrentUserDetails()
        if self.selectedSection == nil {
            self.select(section: .timeline)
        }
//        self.addContentOffsetChangeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.removeContentOffsetChangeObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowTimestampDetailsVC" {
            if let detailsVC = segue.destination as? TimestampDetailsVC {
                detailsVC.timeStamp = sender as! RMTimestamp
                detailsVC.delegate = self
            }
        } else if segue.identifier == "seguePresentMyPageInfoEditVC" {
            if let nav = segue.destination as? UINavigationController,
                let editvc = nav.viewControllers.first as? MyPageInfoEditVC {
                editvc.reloadProfile = {
                    self.refreshUserInfo()
                }
            }
        } else if segue.identifier == "seguePresentEditContactInfoVC" {
            if let nav = segue.destination as? UINavigationController,
                let editvc = nav.viewControllers.first as? EditContactInfoVC {
                editvc.reloadProfile = {
                    self.refreshUserInfo()
                }
            }
        } else if segue.identifier == "seguePresentEditSkillDetailVC" {
            if let nav = segue.destination as? UINavigationController,
                let editvc = nav.viewControllers.first as? EditSkillDetailVC {
                editvc.reloadProfile = {
                    self.refreshUserInfo()
                }
            }
        }
    }
    
    @IBAction func timelineSectionButtonTapped(_ sender: UIButton) {
        self.select(section: .timeline)
    }
    
    @IBAction func basicInformationSectionButtonTapped(_ sender: UIButton) {
        self.select(section: .basicInformation)
    }

    func refreshUserInfo() {
        self.loadUserProfile()
        if let user = APIManager.shared.loginSession?.user {
            self.user = user
            self.basicInformationTableViewAdapter?.loadUserProfile(for: self.user, {
                self.setCurrentUserDetails()
            })
        }
    }

    private func select(section: RMUserProfileSection) {
        
        guard let timelineSectionButton = self.timelineSectionButton else {
            return
        }
        
        guard let basicInformationSectionButton = self.basicInformationSectionButton else {
            return
        }
        
        guard let selectedSectionIndicatorView = self.selectedSectionIndicatorView else {
            return
        }
        
        guard let selectedSectionIndicatorLeadingConstraint = self.selectedSectionIndicatorLeadingConstraint else {
            return
        }
        
        timelineSectionButton.contentVerticalAlignment = .top
        basicInformationSectionButton.contentVerticalAlignment = .top
        
        if section == self.selectedSection {
            return
        }
        
        self.selectedSection = section
        
        var newLeadingMargin: CGFloat = 0
        var contentOffsetX: CGFloat = 0
        var selectedButton: UIButton
        var deselectedButton: UIButton
        
        switch section {
        case .timeline:
            selectedButton = timelineSectionButton
            deselectedButton = basicInformationSectionButton
        case .basicInformation:
            newLeadingMargin = selectedSectionIndicatorView.frame.width
            contentOffsetX = self.scrollView.frame.width
            selectedButton = basicInformationSectionButton
            deselectedButton = timelineSectionButton
        }
        
        UIView.animate(withDuration: 0.27, animations: {
            
            selectedSectionIndicatorLeadingConstraint.constant = newLeadingMargin
            selectedSectionIndicatorView.superview?.layoutIfNeeded()
            
            self.scrollView.contentOffset.x = contentOffsetX
            
        }, completion: { (finished) in
            
            if finished {
                selectedButton.isSelected = true
                deselectedButton.isSelected = false
                
                selectedButton.titleLabel?.font = HiraginoSansW6(withSize: 12)
                deselectedButton.titleLabel?.font = HiraginoSansW4(withSize: 12)
            }
        })
    }

    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueShowMyPageSetting", sender: self)
    }
    
    // MARK: - Table view data source
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//        cell.addSubview(self.scrollView)
//        self.scrollView.frame = cell.bounds
//        self.scrollView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
//        self.scrollView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
//        self.scrollView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
//        self.scrollView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height = tableView.frame.height - (self.tabBarController?.tabBar.frame.height ?? 0) - 26
//        return height
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 35
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 26))
//        view.addSubview(self.headerViewTest)
//
//        self.headerViewTest.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        self.headerViewTest.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        self.headerViewTest.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        self.headerViewTest.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//
//        return view
//    }
}


extension UserProfileTableVC {
    
//    func addContentOffsetChangeObserver() {
//        let options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.new
//        self.timelineTableView.addObserver(self, forKeyPath: "contentOffset", options: options, context: &kvoContextTimelineTableView)
//        self.basicInformationTableView.addObserver(self, forKeyPath: "contentOffset", options: options, context: &kvoContextBasicInfoTableView)
//    }
//
//    func removeContentOffsetChangeObserver() {
//        self.timelineTableView.removeObserver(self, forKeyPath: "contentOffset")
//        self.basicInformationTableView.removeObserver(self, forKeyPath: "contentOffset")
//    }
    
//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey : Any]?,
//                               context: UnsafeMutableRawPointer?) {
//
//        if context == &kvoContextTimelineTableView {
//            if let tableView: UITableView = object as? UITableView {
//                let contentOffsetY: CGFloat = tableView.contentOffset.y
//                if contentOffsetY < self.headerView.frame.height {
//                    let point: CGPoint = CGPoint(x: 0, y: contentOffsetY)
////                    print("Current offset: \(tableView.contentOffset.y)")
//                    self.tableView.setContentOffset(point, animated: false)
//                }
//            }
//        } else if context == &kvoContextBasicInfoTableView {
//            if let tableView: UITableView = object as? UITableView {
//                let contentOffsetY: CGFloat = tableView.contentOffset.y
//                if contentOffsetY < self.headerView.frame.height {
//                    let point: CGPoint = CGPoint(x: 0, y: contentOffsetY)
////                    print("Current offset: \(tableView.contentOffset.y)")
//                    self.tableView.setContentOffset(point, animated: false)
//                }
//            }
//        }
//    }
}

extension UserProfileTableVC: UserTimelineAdapterDelegate {
    func showUserProfile(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            UserProfileVC.loadUserProfile(for: timestamp.user.id, on: self)
        }
    }

    func dataLoadedInTableView() {
        
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
                self.showActionSheet(timeStamp.user.username, message: "", actionTitles:[("delete".localized, UIAlertActionStyle.destructive)], cancelTitle: "Cancel".localized, actionHandler: { (action, index) in
                    if index == 0 {
                        timeStamp.delete({ (success) in
                            if success {
                                self.timelineAdapter?.delete(timeStamp: timeStamp)
                            }
                        })
                    }
                })
            } else {
                self.showActionSheet(timeStamp.user.username, message: "", actionTitles: [("unfollow".localized, UIAlertActionStyle.destructive)], cancelTitle: "Cancel".localized, actionHandler: { (action, index) in
                    
                })
            }
        }
    }
    
    func showLocation(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            OfficeProfileVC.openOfficeProfile(for: timestamp.company.id, on: self)
        }
    }
    
    func didSelect(timeStamp: RMTimestamp?) {
        if let timeStamp = timeStamp {
            self.performSegue(withIdentifier: "segueShowTimestampDetailsVC", sender: timeStamp)
        }
    }
}

extension UserProfileTableVC: TimestampDetailsVCDelegate {
    
    func reload(timestamp: RMTimestamp) {
        self.timelineAdapter?.refresh(with: timestamp)
    }
    
    func delete(timestamp: RMTimestamp) {
        self.timelineAdapter?.delete(timeStamp: timestamp)
    }

    func refreshTimeline() {
        self.loadUserProfile(true)
    }

}

extension UserProfileTableVC: BasicInformationTableViewAdapterDelegate {
    
    func editButtonTapped(for section: BasicInformationTableViewAdapter.Section) {
        switch section.index! {
        case 0:
            self.performSegue(withIdentifier: "seguePresentMyPageInfoEditVC", sender: nil)
            
        case 1:
            self.performSegue(withIdentifier: "seguePresentEditContactInfoVC", sender: nil)

        case 2:
            self.performSegue(withIdentifier: "seguePresentEditSkillDetailVC", sender: nil)

        default:
            break
        }
    }
}
