//
//  ForgotPasswordVC.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnSend: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtEmail.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Forgot Password")
        super.viewWillAppear(animated)
    }

     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowConfirmEmailVC" {
            if let confirmVC = segue.destination as? ConfirmEmailVC {
                confirmVC.email = sender as! String
            }
        }
     }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onSendTap(_ sender: UIBarButtonItem) {
        self.sendRecoveryEmail()
    }

    func sendRecoveryEmail() {
        self.txtEmail.resignFirstResponder()
        if let emailText = self.txtEmail.text,
            emailText.trimString().isValidEmail() {
            self.showLoader()
            APIManager.shared.forgotPassword(for: emailText.trimString(), completion: { (sucess, error) in
                self.hideLoader()
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "segueShowConfirmEmailVC", sender: emailText)
                }
            })
        } else {
            self.showAlert("Required".localized,
                           message: "The email address you requested is not registered".localized)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendRecoveryEmail()
        return true
    }
}

