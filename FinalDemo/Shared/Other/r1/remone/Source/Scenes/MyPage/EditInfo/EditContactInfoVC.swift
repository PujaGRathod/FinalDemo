//
//  EditContactInfoVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class EditContactInfoVC: UITableViewController {

    struct ContactDetailModel {
        let email: String
        var mobileno: String?
        var phoneno: String?

        func getParams() -> [String: Any] {
            var params: [String: Any] = [:]

            if let mobileNo = self.mobileno,
                mobileNo.trimString() != "" {
                params["mobileNo"] = mobileNo
            }

            if let phoneNo = self.phoneno,
                phoneNo.trimString() != "" {
                params["phoneNo"] = phoneNo
            }

            return params
        }
    }

    var dataModel: ContactDetailModel!
    var reloadProfile: UserProfileReload?

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var btnCompleted: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "連絡情報"
        if let user = APIManager.shared.loginSession?.user {
            self.dataModel = ContactDetailModel.init(email: user.email, mobileno: user.mobileNo, phoneno: user.phoneNo)
        } else {
            self.navigationController?.dismiss(animated: true, completion: {

            })
        }
        self.tfEmail.text = self.dataModel.email
        self.tfMobileNumber.text = self.dataModel.mobileno
        self.tfPhoneNumber.text = self.dataModel.phoneno
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Edit Contact Information")
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func validateProfileDetail() -> String {
        var strMessage = ""
        if let emailText = self.tfEmail.text?.trimString(),
                emailText == "",
                emailText.isValidEmail() {
            strMessage = "Please enter email".localized
            return strMessage
        }

        if let mobileNo = self.tfMobileNumber.text?.trimString(),
            mobileNo == "",
            let phoneNo = self.tfPhoneNumber.text?.trimString(),
            phoneNo == "" {
            return "\("Please enter valid mobile number".localized) または \("Please enter valid mobile number".localized)"
        }

        if let mobileNo = self.tfMobileNumber.text?.trimString(),
            mobileNo != "" {
            if mobileNo.count != 10,
                mobileNo.count != 11
                {
                    strMessage = "Please enter valid mobile number".localized
                            return strMessage
                }
        }
        if let phoneNo = self.tfPhoneNumber.text?.trimString(),
            phoneNo != "" {
            if phoneNo.count != 10,
                phoneNo.count != 11
            {

                strMessage = "Please enter valid phone number".localized
                return strMessage
            }
        }
        return strMessage
    }

    @IBAction func onCompleted(_ sender: UIBarButtonItem) {
        let validation = self.validateProfileDetail().trimString()
        if validation != "" {
            self.showAlert("Error".localized, message: validation)
        } else {
            self.dataModel.mobileno = self.tfMobileNumber.text
            self.dataModel.phoneno = self.tfPhoneNumber.text
            let params = self.dataModel.getParams()
            if params.keys.count > 0 {
                self.showLoader()
                APIManager.shared.updateUserProfileDetail(with: params, completion: { (error) in
                    self.hideLoader()
                    if error != nil {
                        self.showAlert("Error".localized, message: error?.localizedDescription)
                    } else {
                        APIManager.shared.loginSession?.user.mobileNo = self.dataModel.mobileno ?? ""
                        APIManager.shared.loginSession?.user.phoneNo = self.dataModel.phoneno ?? ""
                        APIManager.shared.loginSession?.save()
                        self.reloadProfile?()
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
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
