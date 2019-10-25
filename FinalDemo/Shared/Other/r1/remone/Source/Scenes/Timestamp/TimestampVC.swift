//
//  TimestampVC.swift
//  remone
//
//  Created by Akshit Zaveri on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TimestampVC: UIViewController, Refreshable {
    
    @IBOutlet var statusButtonViews: [UIView]!
    @IBOutlet var iconButtons: [UIButton]!
    @IBOutlet var titleLabels: [UILabel]!
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationValueLabel: UILabel!
    
    // Available status
    @IBOutlet weak var availableStatusView: UIView!
    @IBOutlet weak var availableStatusIconButton: UIButton!
    @IBOutlet weak var availableStatusTextLabel: UILabel!
    @IBOutlet weak var availableStatusTappableButton: UIButton!
    
    // Busy status
    @IBOutlet weak var busyStatusView: UIView!
    @IBOutlet weak var busyStatusIconButton: UIButton!
    @IBOutlet weak var busyStatusTextLabel: UILabel!
    @IBOutlet weak var busyStatusTappableButton: UIButton!
    
    // Away status
    @IBOutlet weak var awayStatusView: UIView!
    @IBOutlet weak var awayStatusIconButton: UIButton!
    @IBOutlet weak var awayStatusTextLabel: UILabel!
    @IBOutlet weak var awayStatusTappableButton: UIButton!
    
    @IBOutlet weak var writeStatusTextView: IQTextView!
    
    @IBOutlet var buttonsView: [UIView]!

    @IBOutlet weak var updateButtonsView: UIStackView!
    @IBOutlet weak var startButtonsView: UIView!
    
    @IBOutlet weak var btnFinishWork: UIButton!
    @IBOutlet weak var btnStartWork: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    
    private var unselectedViewBorderColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
    private var unselectedTintColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
    private var selectedTintColor = UIColor.white

    var latestTimeStamp: RMTimestamp?
    // User entered information
    private var selectedStatus: TimeStampStatus?
    private var userTypedstatusText: String?
    
    private var selectedOffice: RMOffice?
    
    private var selectedLocation: RMCompany? {
        didSet {
            if let location = self.selectedLocation {
                self.locationValueLabel.text = location.name
            } else {
                self.locationValueLabel.text = "Office location".localized
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in self.iconButtons {
            button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        }
        self.writeStatusTextView.layer.cornerRadius = 4

        self.selectedStatus = TimeStampStatus.available
        for view in self.buttonsView {
            view.isHidden = true
        }

        self.selectOption(timestamp: TimeStampStatus.available,
                          selectedView: self.availableStatusView,
                          iconButton: self.availableStatusIconButton,
                          titleLabel: self.availableStatusTextLabel)

        self.btnStartWork.layer.cornerRadius = 24
        self.btnStartWork.backgroundColor = APP_COLOR_THEME
        self.btnStartWork.setTitleColor(UIColor.white, for: UIControlState.normal)

        self.btnFinishWork.layer.cornerRadius = 24
        self.btnFinishWork.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
        self.btnFinishWork.layer.borderWidth = 0.5
        self.btnFinishWork.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: UIControlState.normal)
        
        self.btnUpdate.layer.cornerRadius = 24
        self.btnUpdate.backgroundColor = APP_COLOR_THEME
        self.btnUpdate.setTitleColor(UIColor.white, for: UIControlState.normal)

        self.writeStatusTextView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.writeStatusTextView.placeholder = "How are you doing now?".localized

        if [Model.iPhone5, Model.iPhone5S, Model.iPhone5C].contains(UIDevice.current.type) {
            for label in self.titleLabels {
                label.font = HiraginoSansW5(withSize: 12)
            }
        } else {
            for label in self.titleLabels {
                label.font = HiraginoSansW5(withSize: 14)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Add Timestamp")
        //        self.getLatestTimeStamp()
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localized
    }
    
    func refresh() {
        self.getLatestTimeStamp()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.statusButtonViews {
            view.layer.cornerRadius = view.frame.size.width/2
            view.layer.borderColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
            view.layer.borderWidth = 0.5
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLocationPicker" {
            if let navController = segue.destination as? UINavigationController,
                let vc = navController.viewControllers.first as? LocationPickerTableVC {
                vc.selectedLocation = self.selectedLocation
                vc.delegate = self
            }
        }
    }
    
    private func resetUserEnteredInformation() {
        self.selectedStatus = nil
        self.userTypedstatusText = nil
        self.selectedLocation = nil
    }
    
    @IBAction func availableStatusButtonTapped(_ sender: UIButton) {
        self.selectedStatus = TimeStampStatus.available
        self.selectOption(timestamp: TimeStampStatus.available,
                          selectedView: self.availableStatusView,
                          iconButton: self.availableStatusIconButton,
                          titleLabel: self.availableStatusTextLabel)
    }
    
    @IBAction func busyStatusButtonTapped(_ sender: UIButton) {
        self.selectedStatus = TimeStampStatus.busy
        self.selectOption(timestamp: TimeStampStatus.busy,
                          selectedView: self.busyStatusView,
                          iconButton: self.busyStatusIconButton,
                          titleLabel: self.busyStatusTextLabel)
    }
    
    @IBAction func awayStatusButtonTapped(_ sender: UIButton) {
        self.selectedStatus = TimeStampStatus.away
        self.selectOption(timestamp: TimeStampStatus.away,
                          selectedView: self.awayStatusView,
                          iconButton: self.awayStatusIconButton,
                          titleLabel: self.awayStatusTextLabel)
    }

    @IBAction func onStartWorkTap(_ sender: UIButton) {
        self.writeStatusTextView.text = self.writeStatusTextView.text.trimString()
        var strComment =  ""
        if let titleLabel = sender.titleLabel?.text {
            strComment =  "[\(titleLabel)] " + self.writeStatusTextView.text
        } else {
            strComment = self.writeStatusTextView.text
        }

        if let status = self.selectedStatus {
            self.update(status, text: strComment)
        } else {
            self.availableStatusButtonTapped(self.availableStatusIconButton)
            self.update(.available, text: strComment)
        }
    }

    @IBAction func onFinishWork(_ sender: UIButton) {
        self.writeStatusTextView.text = self.writeStatusTextView.text.trimString()
        var strComment =  ""
        if let titleLabel = sender.titleLabel?.text {
            strComment =  "[\(titleLabel)] " + self.writeStatusTextView.text
        } else {
            strComment = self.writeStatusTextView.text
        }
        if let status = self.selectedStatus {
            self.workEnd(status, text:strComment)
        } else {
            self.availableStatusButtonTapped(self.availableStatusIconButton)
            self.workEnd(.available, text:strComment )
        }
    }

    @IBAction func onUpdateTap(_ sender: UIButton) {
        self.writeStatusTextView.text = self.writeStatusTextView.text.trimString()
        let strComment =  self.writeStatusTextView.text ?? ""
        if let status = self.selectedStatus {
            self.update(status, text: strComment)
        } else {
            self.availableStatusButtonTapped(self.availableStatusIconButton)
            self.update(.available, text: strComment)
        }
    }

    func selectOption(timestamp: TimeStampStatus,
                      selectedView: UIView,
                      iconButton: UIButton,
                      titleLabel: UILabel) {

        for view in self.statusButtonViews {
            view.backgroundColor = UIColor.clear
        }
        //        for view in self.buttonsView {
        //            view.isHidden = true
        //        }
        for button in self.iconButtons {
            button.tintColor = self.unselectedTintColor
        }
        for label in self.titleLabels {
            label.textColor = self.unselectedTintColor
        }
        
        selectedView.backgroundColor = timestamp.color
        selectedView.layer.borderColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        selectedView.layer.borderWidth = 0.5
        iconButton.tintColor = self.selectedTintColor
        titleLabel.textColor = self.selectedTintColor

        self.updateButtons()
    }

    func updateButtons() {
        if let stamp = self.latestTimeStamp,
            let status = stamp.status {
            switch status {
            case .workFinish:
                self.startButtonsView.isHidden = false
                self.updateButtonsView.isHidden = true

            default:
                self.startButtonsView.isHidden = true
                self.updateButtonsView.isHidden = false
            }
        } else {
            self.startButtonsView.isHidden = false
            self.updateButtonsView.isHidden = true
        }
    }

    func update(_ status: TimeStampStatus, text: String) {
        //        self.writeStatusTextView.text = self.writeStatusTextView.text.trimString()
        if let loc = self.selectedLocation,
            loc != RMCompany.getWorkFinishLocation() {
            //            if let text = self.writeStatusTextView.text,
            //                !text.isEmpty,
            //                text != "" {
            self.userTypedstatusText = text
            self.showLoader()
            APIManager.shared.addTimestamp(with: status, withComment:text, at: loc, completion: { (error) in
                self.hideLoader()
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    Analytics.shared.trackTimestampPost(with: status)
                    Analytics.shared.trackTimestampPost(for: loc)
                    self.updateTimeline()
                    self.selectedLocation = nil
                    self.selectedOffice = nil
                    self.userTypedstatusText = nil
                    self.writeStatusTextView.text = ""
                }
            })
            // REMOVED on client's request
            //            } else {
            //                self.showAlert("Required".localized,
            //                               message: "Please add a comment".localized,
            //                               actionHandler: { (action) in
            //                                self.writeStatusTextView.becomeFirstResponder()
            //                })
            //            }
        } else {
            self.selectedLocation = nil
            self.showAlert("Required".localized, message: "Please choose a location".localized)
        }
    }

    func getLatestTimeStamp() {
        self.showLoader()
        if let userid = APIManager.shared.loginSession?.user.id {
            _ = APIManager.shared.getTimeline(for: userid, at: 0, size: 1) { (timeStamps, error, pagination) in
                self.hideLoader()
                self.latestTimeStamp = timeStamps.first
                if let latest = self.latestTimeStamp,
                    latest.status != TimeStampStatus.workFinish,
                    self.selectedOffice == nil {
                    self.selectedLocation = latest.company
                }
                self.updateButtons()
            }
        }
    }

    func postFinishWork(with comment: String, at location: RMCompany) {
        APIManager.shared.addTimestamp(with: .workFinish, withComment:comment, at: RMCompany.getWorkFinishLocation()) { (error) in
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                Analytics.shared.trackTimestampPost(with: TimeStampStatus.workFinish)
                Analytics.shared.trackTimestampPost(for: location)
                self.updateTimeline()
            }
            self.selectedOffice = nil
            self.selectedLocation = nil
            self.userTypedstatusText = nil
            self.writeStatusTextView.text = ""
        }
    }

    func workEnd(_ status: TimeStampStatus,text:String) {
        if let location = self.selectedLocation {
            //            if let text = self.writeStatusTextView.text,
            //                !text.isEmpty {
            self.userTypedstatusText = text
            self.showAlert("End work".localized,
                           message: "Do you want to end today's work?".localized,
                           actionTitles: [("Cancel".localized, .cancel), ("finish".localized, .default)],
                           actionHandler: { (action, index) in
                            if index == 1 {
                                self.showAlert("I have finished my work".localized,
                                               message: "Today a cheers for good work.".localized,
                                               actionHandler: { (action) in
                                                self.postFinishWork(with: text, at: location)

                                })
                            }
            })
            //            } else {
            //                self.showAlert("Required".localized,
            //                               message: "Please add a comment".localized,
            //                               actionHandler: { (action) in
            //                                self.writeStatusTextView.becomeFirstResponder()
            //                })
            //            }
        } else {
            self.showAlert("Required".localized, message: "Please choose a location".localized)
        }
    }

    func updateTimeline() {
        //        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "ReloadTimeline")))
        if let _ = self.tabBarController?.viewControllers?.first as? UINavigationController {
            //            if let timelineVC = timelineNav.viewControllers.first as? UserTimelineVC {
            //                timelineVC.adapter.reloadTimeline()
            //            }
            self.tabBarController?.selectedIndex = 0
        } else if (self.navigationController?.isBeingPresented ?? false) ||
            (self.navigationController?.presentingViewController != nil) {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        self.getLatestTimeStamp()
    }

    func timeStampFor(_ office:RMOffice) {
        self.selectedLocation = office.convertToCompany()
    }

    @objc func onBack(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {

        })
    }

    func addBackButton() {
        let backButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.onBack(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton
    }

    class func openTimeStamp(for office: RMOffice, on vc: UIViewController) {
        let story = UIStoryboard.init(name: "Timestamp", bundle: nil)
        if let nav = story.instantiateViewController(withIdentifier: "navTimestamp") as? UINavigationController {
            if let timeStampVC = nav.viewControllers.first as? TimestampVC {
                timeStampVC.selectedOffice = office
                timeStampVC.getLatestTimeStamp()
                vc.present(nav, animated: true, completion: {
                    timeStampVC.addBackButton()
                    timeStampVC.timeStampFor(office)
                })
            }
        }
    }

}

extension TimestampVC: LocationPickerTableDelegate {

    func companySelected(_ location: RMCompany) {
        self.selectedLocation = location
    }
}
