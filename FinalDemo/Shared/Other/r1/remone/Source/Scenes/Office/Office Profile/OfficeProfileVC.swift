//
//  OfficeProfileVC.swift
//  remone
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import SafariServices

class OfficeProfileVC: UIViewController {

    @IBOutlet weak var viewNoInfo: UIView!
    @IBOutlet weak var viewInfoNotice: UIView!
    @IBOutlet weak var conHeightViewInfoNotice: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var btnFav: UIBarButtonItem!
    var btnTimeStamp: UIBarButtonItem!
    @IBOutlet weak var lblImageCount: UILabel!
    @IBOutlet weak var colOfficeImages: UICollectionView!
    @IBOutlet weak var viewHeader: UIView!

    var adapter: OfficeProfileAdapter!
    var imageAdapter: OfficeProfileImageAdapter!
    var office: RMOffice!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.lblImageCount.layer.cornerRadius = 12
        self.lblImageCount.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Office Profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowUsersListTableVC" {
            if let userlistVC = segue.destination as? UsersListTableVC {
                userlistVC.users = sender as! [RMUser]
            }
        }
    }


    func loadOfficeProfileFor(_ officeID: String) {
        self.showLoader()
        APIManager.shared.getCompanyProfile(for: officeID) { (office, error) in
            if let office = office {
                self.viewNoInfo.isHidden = true
                self.office = office
                self.adapter = OfficeProfileAdapter.init(with: self.tableView, delegate: self, with: office)
                self.imageAdapter = OfficeProfileImageAdapter.init(with: self.colOfficeImages, delegate: self, with: office.images)
                self.setupButtons()
            } else if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
                self.viewNoInfo.isHidden = false
            } else {
                self.viewNoInfo.isHidden = false
            }
            self.hideLoader()
        }

    }

    func setupButtons() {

        if self.office.isPartnerShop {
            self.conHeightViewInfoNotice.constant = 0
            self.view.layoutIfNeeded()
        } else {
            self.conHeightViewInfoNotice.constant = 44
            self.view.layoutIfNeeded()
        }

        self.btnTimeStamp = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconOfficeTimeStamp"), style: .plain, target: self, action: #selector(self.onTimeStamp(_:)))
        self.btnTimeStamp.tintColor = APP_COLOR_THEME

        APIManager.shared.getFavoriteOffices { (list, _) in
            var favImage = #imageLiteral(resourceName: "iconFavoriteEmpty")
            if list.contains(self.office) {
                favImage = #imageLiteral(resourceName: "iconFavoriteFilled")
            }
            self.btnFav = UIBarButtonItem.init(image: favImage, style: .plain, target: self, action: #selector(self.onFavTap(_:)))
            self.btnFav.tintColor = APP_COLOR_THEME
            self.navigationItem.rightBarButtonItems = [self.btnFav, self.btnTimeStamp]
        }
    }

    @objc func onTimeStamp(_ sender: UIBarButtonItem) {
        TimestampVC.openTimeStamp(for: self.office, on: self)
    }

    @objc func onFavTap(_ sender: UIBarButtonItem) {
        self.showLoader()
        APIManager.shared.markAsFavorite(officeID: self.office.id) { (error) in
            self.hideLoader()
            self.setupButtons()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {

            }
        }
    }

    @objc func onBack(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {

        })
    }

    func addBackButton() {
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBack(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton
    }

    class func openOfficeProfile(for officeId: String, on vc: UIViewController) {
        let story = UIStoryboard.init(name: "OfficeProfile", bundle: nil)
        if let nav = vc.navigationController {
            if let officeProfilevc = story.instantiateViewController(withIdentifier: "OfficeProfileVC") as? OfficeProfileVC {
                nav.pushViewController(officeProfilevc, animated: true)
                officeProfilevc.loadOfficeProfileFor(officeId)
            }
        } else if let nav = story.instantiateViewController(withIdentifier: "navOfficeProfile") as? UINavigationController {
            if let officeProfilevc = nav.viewControllers.first as? OfficeProfileVC {
                vc.present(nav, animated: true, completion: {
                    officeProfilevc.loadOfficeProfileFor(officeId)
                    officeProfilevc.addBackButton()
                })
            }
        }
    }
    
}

extension OfficeProfileVC: OfficeProfileImageAdapterDelegate, OfficeProfileAdapterDelegate {

    func openURL(_ url: URL?) {
        if let url = url {

//            let safariVC = SFSafariViewController.init(url: url)
//            if #available(iOS 10.0, *) {
//                safariVC.preferredBarTintColor = APP_COLOR_THEME
//                safariVC.preferredControlTintColor = APP_COLOR_THEME
//            } else {
//            }
//            self.present(safariVC, animated: true, completion: nil)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }

    func showLoader(_ show: Bool) {
        if show {
            self.showLoader()
        } else {
            self.hideLoader()
        }
    }

    func showAlertForFollowRequest(yes: @escaping () -> (), no: () -> ()) {
        self.showAlert("",
                       message: "Do you want to delete follow request?".localized,
                       actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                       cancelTitle: "no".localized,
                       actionHandler: { (action, _) in
                        yes()
        },
                       cancelActionHandler: nil)
    }
    
    func showAlertForStopFollowRequest(yes: @escaping () -> (), no: () -> ()) {
        self.showAlert("",
                       message: "Do you want to stop following?".localized,
                       actionTitles: [("yes".localized, UIAlertActionStyle.destructive)],
                       cancelTitle: "no".localized,
                       actionHandler: { (action, _) in
                        yes()
        },
                       cancelActionHandler: nil)
    }
    
    func openMaps() {
        let coord = self.office.location.coordinates
        let qLatLon = URLQueryItem.init(name: "ll", value: "\(coord.latitude),\(coord.longitude)")
        let qName = URLQueryItem.init(name: "q", value: self.office.name)
        var comps = URLComponents.init()
        comps.scheme = "http"
        comps.host = "maps.apple.com"
        comps.queryItems = [qLatLon, qName]
//        let urlString = "http://maps.apple.com/?ll=&q=\(self.office.name)"
//        if let mapURL = URL(string: urlString) {
//            UIApplication.shared.open(mapURL, options: [:], completionHandler: nil)
//        }
        if let url = comps.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func reportOffice() {
        OfficeReportVC.presentOfficeReport(on: self, with: self.office)
    }

    func showMoreUsers() {
        self.performSegue(withIdentifier: "segueShowUsersListTableVC", sender: self.office.users)
    }

    func updateIndexTitle(_ title: String) {
        self.lblImageCount.text = title
    }

    func showUserProfile(for id: String) {
        UserProfileVC.loadUserProfile(for: id, on: self)
    }
}
