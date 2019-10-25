//
//  MyPageSettingVCTableViewController.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class MyPageSettingTableVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate {
    
    var isUpdateProfile: Bool = true
    
    @IBOutlet var tblView: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var imgCover: RMUserCoverImageView!
    @IBOutlet weak var imgProfile: RMUserProfileImageView!
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var btnChangeProfile: UIButton!
    @IBOutlet weak var btnLogOut: UIButton!
    @IBOutlet weak var informationDisclosureValueLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!

    var followingList: [RMUser] = [RMUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Configuration".localized
        self.btnLogOut.layer.cornerRadius = 3
        self.btnLogOut.layer.borderColor = UIColor(red: 13.0/255.0, green: 63.0/255.0, blue: 158.0/255.0, alpha: 1).cgColor
        self.btnLogOut.layer.borderWidth = 0.5
        self.btnLogOut.layer.masksToBounds = true

        if isiOS10() {
            let footer = self.tableView.tableFooterView
            footer?.frame.size.height += 44
            self.tableView.tableFooterView = footer
            self.tableView.reloadData()
        }

        self.setCurrentUserDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "My Page Settings")
        self.updateFollowingCounts(with: nil)
    }
    
    private func setCurrentUserDetails() {
        if let user = APIManager.shared.loginSession?.user {
            self.imgProfile.set(url: user.profilePicture)
            self.imgCover.set(url: user.coverPicture)
            self.updateDisclosureValue()
            self.updateManagerName()
        }
    }

    private func updateManagerName() {
        if let user = APIManager.shared.loginSession?.user {
            self.managerLabel.text = user.manager?.name
        }
    }
    
    private func updateDisclosureValue() {
        if let user = APIManager.shared.loginSession?.user {
            self.informationDisclosureValueLabel.text = (user.settings[.disclosureInfo] ?? true) ? "on".localized : "off".localized
        }
    }
    
    private func updateFollowingCounts(with count: Int?) {
        func set(count: Int) {
            self.followingCountLabel.text = "\(count)"
        }
        if let count = count {
            set(count: count)
        } else {
            _ = APIManager.shared.getFollowingUsers({ (users, error) in
                if let _ = error {
//                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    set(count: users.count)
                }
            })
        }
    }
    
    //MARK:- Class Methods
    func performAction(indexpath:IndexPath) {
        
        switch indexpath.section {
        case 0:
            switch indexpath.row {
            case 0:
                self.performSegue(withIdentifier: "segueShowinfoDisclosureVC", sender: self)
                
            case 1:
                if APIManager.shared.loginSession?.user.role == .user {
                    self.performSegue(withIdentifier: "segueShowUserManagerSelectionVC", sender: self)
                } else {
                    self.showAlert("Permission denied".localized, message: "You are not allowed to change this setting".localized)
                }
                
            case 2:
                self.performSegue(withIdentifier: "segueShowUserFollowListVC", sender: self)
                
            default:
                break
            }

        case 1:
            self.performSegue(withIdentifier: "segueShowImageUploaderVC", sender: self)

        default:
            break
        }
        
    }

    func openGallery() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    func openCamera() {
        let picker = UIImagePickerController()
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Not Found".localized, message: "This device has no Camera".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showImageChangeAction()  {
        
        let actionSheet = UIAlertController(title: "Select image from".localized, message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Device photo library".localized, style: .default, handler: { (action) in
            self.openGallery()
        }))
        
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { (action) in
                self.openCamera()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action) in
            
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setProfileImage(image:UIImage) {
        self.imgProfile.image = image
        self.showLoader()
        APIManager.shared.uploadProfileImage(image, { (result, error) in
            APIManager.shared.loginSession?.updateUser() {
                self.hideLoader()
            }
        })
    }
    
    func setCoverImage(image:UIImage)  {
        self.imgCover.image = image
        self.showLoader()
        APIManager.shared.uploadCoverImage(image) { (result, error) in
            APIManager.shared.loginSession?.updateUser() {
                self.hideLoader()
            }
        }
    }
    
    @IBAction func changeCoverPic(_ sender: UIButton) {
        self.isUpdateProfile = false
        self.showImageChangeAction()
    }
    
    @IBAction func ChangeProfilePic(_ sender: UIButton) {
        self.isUpdateProfile = true
        self.showImageChangeAction()
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        self.showAlert("Please confirm".localized,
                       message: "",
                       actionTitles: [("Logout".localized, UIAlertActionStyle.destructive)],
                       cancelTitle: "Cancel".localized,
                       actionHandler: { (_, _) in

                        self.showLoader()
                        APIManager.shared.loginSession?.logout {
                            self.hideLoader()
                            RMLoginSession.setupLogoutFlow()
                            APIManager.shared.loginSession = nil
                        }
        },
                       cancelActionHandler: nil)
    }
    
    // MARK: - imagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if isUpdateProfile {
            self.setProfileImage(image: chosenImage)
        } else {
            self.setCoverImage(image: chosenImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print(indexPath)
        self.performAction(indexpath: indexPath)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowUserManagerSelectionVC",
            let vc = segue.destination as? UserManagerSelectionVC {
            vc.selectedManager = APIManager.shared.loginSession?.user.manager
            vc.reloadProfile = {
                self.updateManagerName()
            }
        } else if segue.identifier == "segueShowinfoDisclosureVC",
            let vc = segue.destination as? MyPageInfoDisclosureVC {
            vc.reloadProfile = {
                self.updateDisclosureValue()
            }
        } else if segue.identifier == "segueShowUserFollowListVC",
            let vc = segue.destination as? UserFollowListVC {
            vc.reloadProfile = { count in
                self.updateFollowingCounts(with: count)
            }
        }
    }
}
