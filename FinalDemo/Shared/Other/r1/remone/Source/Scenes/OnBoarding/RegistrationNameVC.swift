//
//  RegistrationNameVC.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class RegistrationNameVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtRuby: UITextField!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Register Name")

        self.navigationController?.removeShadowFromNavigationbar()
        let session = APIManager.shared.loginSession
        self.txtName.text = session?.user.name
        self.txtRuby.text = session?.user.ruby

        self.txtRuby.delegate = self
        self.txtName.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func onNextTap(_ sender: UIBarButtonItem) {
        self.next()
    }

    func next() {
        if let nameString = self.txtName.text,
            !nameString.isEmpty {
            let session = APIManager.shared.loginSession
            session?.user.name = nameString
            session?.user.isSignupComplete = false
            session?.save()
            self.showLoader()
            session?.user.updateProfile({ (success) in
                self.hideLoader()
                if success {
                    self.performSegue(withIdentifier: "segueRegistrationCompanyVC", sender: nil)
                } else {
                    self.showAlert("Failed".localized,
                                   message: "Data could not be saved!".localized)
                }
            })
        } else {
            self.showAlert("Required".localized, message: "All fields are required!".localized)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtName {
            self.txtRuby.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.next()
        }
        return true
    }
}
