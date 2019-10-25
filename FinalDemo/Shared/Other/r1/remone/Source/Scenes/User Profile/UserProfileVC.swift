//
//  UserProfileVC.swift
//  remone
//
//  Created by Akshit Zaveri on 26/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

typealias UserProfileReload = () -> Void

class UserProfileVC: TwitterProfileViewController {
    
    enum RMUserProfileSection {
        case timeline
        case basicInformation
    }
    var shouldConsiderSettings: Bool = false

    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet private weak var selectedSectionIndicatorView: UIView?
    @IBOutlet private weak var timelineSectionButton: UIButton?
    @IBOutlet private weak var basicInformationSectionButton: UIButton?
    @IBOutlet private weak var selectedSectionIndicatorLeadingConstraint: NSLayoutConstraint?
    
    private var timelineAdapter: UserTimelineAdapter?
    @IBOutlet private var timelineTableView: UITableView!
    
    private var basicInformationTableViewAdapter: BasicInformationTableViewAdapter?
    @IBOutlet private var basicInformationTableView: UITableView!
    
    private var selectedSection: RMUserProfileSection?
    
    var user: RMUser!
    var userID: String?
    var isCurrentUser: Bool {
        if self.userID == APIManager.shared.loginSession?.user.id {
            return true
        }
        return false
    }
    
    class func loadUserProfile(for id: String, on vc: UIViewController, shouldConsiderSettings: Bool = false) {
        let story = UIStoryboard.init(name: "UserProfile", bundle: nil)
        if let navProfile = story.instantiateViewController(withIdentifier: "navUserProfile") as? UINavigationController {
            if let profileVC = navProfile.viewControllers.first as? UserProfileVC {
                profileVC.userID = id
                profileVC.addbackButton()
                vc.present(navProfile, animated: true, completion: {
                    
                })
            }
        }
    }
    
    override func viewDidLoad() {
        self.tabOptionsView = self.headerView
        super.viewDidLoad()

        if isiOS10() {
            let footer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 0))
            footer.frame.size.height += 54
            self.timelineTableView.tableFooterView = footer

            let footer1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 0))
            footer1.frame.size.height += 54
            self.basicInformationTableView.tableFooterView = footer
        }
        self.viewNoDataFound.backgroundColor = .white
        self.timelineTableView.backgroundColor = UIColor.white
        self.basicInformationTableView.backgroundColor = UIColor.white
        self.basicInformationTableView.separatorStyle = .none
        self.view.backgroundColor = self.timelineTableView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblNoDataFound.text = ""
        self.loadUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func refreshUserInfo() {
//        self.loadUserProfile()
        if let user = APIManager.shared.loginSession?.user {
            self.user = user
            self.basicInformationTableViewAdapter?.loadUserProfile(for: self.user, {
                self.setCurrentUserDetails()
            })
        }
    }
    
    func addbackButton() {
        let backBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backBtn.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    // MARK: Twitter like UI methods
    override func numberOfSegments() -> Int {
        return 2
    }
    
    override func segmentTitle(forSegment index: Int) -> String {
        return "Segment \(index)"
    }
    
    override func prepareForLayout() {
        super.prepareForLayout()
        
        self.basicInformationTableViewAdapter = BasicInformationTableViewAdapter.init(with: self.basicInformationTableView, delegate: self)
        self.timelineAdapter = UserTimelineAdapter(with: self.timelineTableView, withDelegate: self)
    }
    
    override func scrollView(forSegment index: Int) -> UIScrollView {
        switch index {
        case 0:
            return self.timelineTableView
        default:
            return self.basicInformationTableView
        }
    }
    // MARK: ----------------------
    
    private func setCurrentUserDetails() {
        if let user = APIManager.shared.loginSession?.user {
            self.profileHeaderView.setProfileImage(url: user.profilePicture)
            self.profileHeaderView.setCoverImage(url: user.coverPicture)
        }
    }


    func sendFollowRequest() {
        func sendRequest() {
            self.showLoader()
            self.user.followUnfollowUser { (success) in
                self.hideLoader()
                if success {
                    self.user.followStatus = self.user.followStatus.getNewStatus
                    self.profileHeaderView.btnFollowing.apply(theme: self.user.followStatus.getTheme)
                } else {
                    self.profileHeaderView.btnFollowing.apply(theme: self.user.followStatus.getTheme)
                }
            }
        }

        if self.user.followStatus == .requested {
            self.showAlert("",
                           message: "Do you want to delete follow request?".localized,
                           actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                           cancelTitle: "no".localized,
                           actionHandler: { (action, _) in
                            sendRequest()
            },
                           cancelActionHandler: nil)
        }
        else if self.user.followStatus == .following {
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

    func confirmAllTimeStamps() {
        if self.user.isFromSameTeam &&
            RMUser.isCurrentRoleManager() &&
            !self.user.isCurrentUser() {
            APIManager.shared.confirmAllTimeStamp(for: self.user.id, {
                self.timelineAdapter?.updateUser(id: self.user.id)
            })
        }
    }

    @objc func changeFavStatus() {
        self.showLoader()
        APIManager.shared.changeFavUserStatus(for: self.user.id) { (error) in
            self.hideLoader()
            if let error = error {
//                self.hideLoader()
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.checkfavStatus {
                }
            }
        }
    }

    func checkfavStatus(_ completion: @escaping ()-> Void) {
        APIManager.shared.checkFavStatus(for: self.user.id) { (isFav) in
            if !self.isCurrentUser {
                var favButton: UIBarButtonItem
                if isFav {
                    favButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconFavoriteFilled"), style: .plain, target: self, action: #selector(self.changeFavStatus))

                } else {
                    favButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconFavoriteEmpty"), style: .plain, target: self, action: #selector(self.changeFavStatus))
                }
                self.navigationItem.rightBarButtonItem = favButton
            }
            completion()
        }
    }
    
    func showNoDataView(_ show: Bool) {
        if show {
            self.view.bringSubview(toFront: self.viewNoDataFound)
            self.viewNoDataFound.isHidden = false
            UIView.animate(withDuration: 0.27, animations: {
                self.viewNoDataFound.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.27, animations: {
                self.viewNoDataFound.alpha = 0
            }, completion: { (_) in
                self.viewNoDataFound.isHidden = true
                self.view.sendSubview(toBack: self.viewNoDataFound)
            })
        }
    }
    
    func loadUserProfile(_ showLoader: Bool = true) {
        func reloadUI() {
            self.confirmAllTimeStamps()
            if self.user.shouldShowUser {
                self.lblNoDataFound.text = ""
                self.showNoDataView(false)
            } else {
                self.hideLoader()
                self.lblNoDataFound.text = "No data found!".localized
                self.showNoDataView(true)
                return;
            }
            if self.isCurrentUser {
                self.title = "My Page".localized
                Analytics.shared.trackScreen(name: "My Page")
                self.profileHeaderView.btnFollowing.apply(theme: RMFollowButtonThemeUnknown())
                self.profileHeaderView.isFromTeam(false)
                self.setCurrentUserDetails()
                self.basicInformationTableViewAdapter?.hideEdit = false
                let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
                self.navigationItem.rightBarButtonItem = btnSettings
            } else {
                self.title = self.user.name
                Analytics.shared.trackScreen(name: "User Profile")
                self.checkfavStatus {
                    
                }
                self.profileHeaderView.btnFollowing.apply(theme: user.followStatus.getTheme)
                self.navigationItem.rightBarButtonItem = nil
                self.basicInformationTableViewAdapter?.hideEdit = true
                self.profileHeaderView.onFollowTap = {
                    self.sendFollowRequest()
                }
            }
            self.profileHeaderView.set(user: self.user)
            self.profileHeaderView.setProfileImage(url: self.user.profilePicture)
            self.profileHeaderView.setCoverImage(url: self.user.coverPicture)
            self.basicInformationTableViewAdapter?.loadUserProfile(for: self.user) {
                //                if self.selectedSection == nil {
                //                    self.select(section: .timeline)
                //                }
                
                //                self.hideLoader()
            }
            self.timelineAdapter?.updateUser(id: self.user.id)
            //            self.timelineAdapter?.reloadTimeline()
            self.getLatestTimeStamp()
        }
        
        func noUserFound() {
            self.hideLoader()
            self.lblNoDataFound.text = "No data found!".localized
            self.showNoDataView(true)
            if !self.isCurrentUser {
                //                self.showAlert("Error!".localized, message: "Data not found!".localized, actionHandler: { (_) in
                //                    self.navigationController?.dismiss(animated: true, completion: nil)
                //                })
            } else {
                //                let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
                //                self.navigationItem.rightBarButtonItem = btnSettings
                //                self.showAlert("Error!".localized, message: "Data not found!".localized, actionHandler: { (_) in
                //                    //                    APIManager.shared.loginSession?.logout()
                //                    //                    RMLoginSession.setupLogoutFlow()
                //                })
            }
        }
        
        self.showLoader()
        if let id = self.userID {
            APIManager.shared.getUserProfile(for: id) { (fetchedUser, error) in
                if let fetchedUser = fetchedUser {
                    self.user = fetchedUser
                    APIManager.shared.getgardnerProfile(for: self.user, completion: { (gardnerStyle, hollands, positive) in
                        self.user.gardnerLearningStyle = gardnerStyle
                        self.user.hollandInsights = hollands
                        self.user.positiveAttributes = positive
                        reloadUI()
                    })
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
                    APIManager.shared.loginSession?.user = self.user
                    APIManager.shared.loginSession?.save()
                    APIManager.shared.getgardnerProfile(for: self.user, completion: { (gardnerStyle, hollands, positive) in
                        self.user.gardnerLearningStyle = gardnerStyle
                        self.user.hollandInsights = hollands
                        self.user.positiveAttributes = positive
                        APIManager.shared.loginSession?.user = self.user
                        APIManager.shared.loginSession?.save()
                        reloadUI()
                    })
                } else if let error = error {
                    self.hideLoader()
                    noUserFound()
                    self.showAlert("Error!".localized, message: error.localizedDescription, actionHandler: { (_) in
                        
                    })
                } else {
                    noUserFound()
                }
            }
        }
    }
    
/*
    func loadUserProfile(_ showLoader: Bool = true) {
        func reloadUI() {
            self.confirmAllTimeStamps()
            if self.isCurrentUser {
                self.title = "My Page".localized
                Analytics.shared.trackScreen(name: "My Page")
                self.profileHeaderView.btnFollowing.apply(theme: RMFollowButtonThemeUnknown())
                self.profileHeaderView.isFromTeam(false)
                self.setCurrentUserDetails()
                self.basicInformationTableViewAdapter?.hideEdit = false
                let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
                self.navigationItem.rightBarButtonItem = btnSettings
            } else {
                self.title = self.user.name
                Analytics.shared.trackScreen(name: "User Profile")
                self.checkfavStatus {

                }
                self.profileHeaderView.btnFollowing.apply(theme: user.followStatus.getTheme)
                self.navigationItem.rightBarButtonItem = nil
                self.basicInformationTableViewAdapter?.hideEdit = true
                self.profileHeaderView.onFollowTap = {
                    self.sendFollowRequest()
                }
            }
            self.profileHeaderView.set(user: self.user)
            self.profileHeaderView.setProfileImage(url: self.user.profilePicture)
            self.profileHeaderView.setCoverImage(url: self.user.coverPicture)
            self.basicInformationTableViewAdapter?.loadUserProfile(for: self.user) {
                //                if self.selectedSection == nil {
                //                    self.select(section: .timeline)
                //                }
                
//                self.hideLoader()
            }
            self.timelineAdapter?.updateUser(id: self.user.id)
            //            self.timelineAdapter?.reloadTimeline()
            self.getLatestTimeStamp()
        }
        
        func noUserFound() {
            self.hideLoader()
            if !self.isCurrentUser {
                self.showAlert("Error!".localized, message: "Data not found!".localized, actionHandler: { (_) in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            } else {
                let btnSettings = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_settings_18pt"), style: .plain, target: self, action: #selector(self.onSettingsTap(_:)))
                self.navigationItem.rightBarButtonItem = btnSettings
                self.showAlert("Error!".localized, message: "Data not found!".localized, actionHandler: { (_) in
                    //                    APIManager.shared.loginSession?.logout()
                    //                    RMLoginSession.setupLogoutFlow()
                })
            }
        }
        
        self.showLoader()
        if let id = self.userID {
            APIManager.shared.getUserProfile(for: id) { (fetchedUser, error) in
                if let fetchedUser = fetchedUser {
                    self.user = fetchedUser
                    APIManager.shared.getgardnerProfile(for: self.user, completion: { (gardnerStyle, hollands, positive) in
                        self.user.gardnerLearningStyle = gardnerStyle
                        self.user.hollandInsights = hollands
                        self.user.positiveAttributes = positive
                        reloadUI()
                    })
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
                    APIManager.shared.loginSession?.user = self.user
                    APIManager.shared.loginSession?.save()
                    APIManager.shared.getgardnerProfile(for: self.user, completion: { (gardnerStyle, hollands, positive) in
                        self.user.gardnerLearningStyle = gardnerStyle
                        self.user.hollandInsights = hollands
                        self.user.positiveAttributes = positive
                        APIManager.shared.loginSession?.user = self.user
                        APIManager.shared.loginSession?.save()
                        reloadUI()
                    })
                } else if let error = error {
                    self.hideLoader()
                    self.showAlert("Error!".localized, message: error.localizedDescription, actionHandler: { (_) in
                        
                    })
                } else {
                    noUserFound()
                }
            }
        }
    }
 */
    func getLatestTimeStamp() {
//        self.showLoader()
        if let id = self.userID {
            _ = APIManager.shared.getTimeline(for: id, at: 0, size: 1) { (timeStamps, error, pagination) in
//                self.hideLoader()
                let timestamp = timeStamps.first
                if let ts = timestamp {
                    self.profileHeaderView.set(timestamp: ts)
                    self.profileHeaderView.set(delegate: self)
                    self.shouldUpdateScrollViewContentFrame = true
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @IBAction func onSettingsTap(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueShowMyPageSetting", sender: nil)
    }
    
    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        if self.navigationController?.presentingViewController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func timelineSectionButtonTapped(_ sender: UIButton) {
        self.select(section: UserProfileVC.RMUserProfileSection.timeline)
    }
    
    @IBAction func basicInformationSectionButtonTapped(_ sender: UIButton) {
        self.select(section: UserProfileVC.RMUserProfileSection.basicInformation)
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
        var selectedButton: UIButton
        var deselectedButton: UIButton
        
        switch section {
        case .timeline:
            selectedButton = timelineSectionButton
            deselectedButton = basicInformationSectionButton
            self.timelineButtonTapped()
        case .basicInformation:
            newLeadingMargin = selectedSectionIndicatorView.frame.width
            self.basicProfileButtonTapped()
            selectedButton = basicInformationSectionButton
            deselectedButton = timelineSectionButton
        }
        
        UIView.animate(withDuration: 0.27, animations: {
            
            selectedSectionIndicatorLeadingConstraint.constant = newLeadingMargin
            selectedSectionIndicatorView.superview?.layoutIfNeeded()
            
        }, completion: { (finished) in
            
            if finished {
                selectedButton.isSelected = true
                deselectedButton.isSelected = false
                
                selectedButton.titleLabel?.font = HiraginoSansW6(withSize: 12)
                deselectedButton.titleLabel?.font = HiraginoSansW4(withSize: 12)
            }
        })
    }

}

extension UserProfileVC: UserTimelineAdapterDelegate {

    public override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.currentIndex == 0 {
            var contentOffset = scrollView.contentOffset
            print("Offset: \(contentOffset)")
            contentOffset.y += self.profileHeaderViewHeight + 29
            
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 6.0,
                !(self.timelineAdapter?.isLoadingData ?? true) {
                if let adapter = self.timelineAdapter {
                    adapter.loadTimeline(at: adapter.paging.currentPage + 1)
                }
            }
        }
    }

    func loadMore(for scrollView: UIScrollView) {
    }

    func pullToRefresh() {
        
    }
    
    func showUserProfile(timestamp: RMTimestamp?) {
        if let timestamp = timestamp {
            if self.user != timestamp.user {
                UserProfileVC.loadUserProfile(for: timestamp.user.id, on: self)
            }
        }
    }

    func dataLoadedInTableView(_ newDataFound: Bool) {
        self.timelineTableView.reloadData()
        self.shouldUpdateScrollViewContentFrame = true
        self.view.layoutIfNeeded()
        self.updateScrollViewContent(newDataFound)
        self.hideLoader()
//        if self.selectedSection == nil {
//            self.select(section: .timeline)
//        }
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
                self.showActionSheet(nil, message: nil, actionTitles:[("delete".localized, UIAlertActionStyle.destructive)], cancelTitle: "Cancel".localized, actionHandler: { (action, index) in

                    if index == 0 {
                        timeStamp.delete({ (success) in
                            if success {
                                self.timelineAdapter?.delete(timeStamp: timeStamp)
                            }
                        })
                    }
                })
            } else {
                self.showActionSheet(nil, message: nil, actionTitles: [("Unfollow".localized, UIAlertActionStyle.destructive)], cancelTitle: "Cancel".localized, actionHandler: { (action, index) in
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
}

extension UserProfileVC: TimestampDetailsVCDelegate {
    func refreshTimeline() {
//        self.loadUserProfile(true)
    }

    func reload(timestamp: RMTimestamp) {
        self.timelineAdapter?.refresh(with: timestamp)
    }
    
    func delete(timestamp: RMTimestamp) {
        self.timelineAdapter?.delete(timeStamp: timestamp)
    }
    
}

extension UserProfileVC: BasicInformationTableViewAdapterDelegate {
    
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

extension UserProfileVC: RMUserInfoViewDelegate {
    func openOfficeProfile(for id: String) {
        OfficeProfileVC.openOfficeProfile(for: id, on: self)
    }
}
