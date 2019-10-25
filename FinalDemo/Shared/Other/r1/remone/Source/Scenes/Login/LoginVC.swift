//
//  LoginVC.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    private var userlocation: UserLocation!

    private var loginCompletion: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.removeShadowFromNavigationbar()

        // Do any additional setup after loading the view.
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
        self.updateLocationSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Login")
        super.viewWillAppear(animated)
        self.txtEmail.becomeFirstResponder()
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue, with sender: Any?) {
        self.loginFinished()
    }

    @IBAction func onForgotPasswordTap(_ sender: UIButton) {

    }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.loginFinished()
    }

    @IBAction func onNextTap(_ sender: UIBarButtonItem) {
        self.login()
    }

    func updateLocationSetup() {
        self.userlocation = UserLocation.init(locationUpdatedBlock: { (location, error) in
            if let _ = error {
            } else if let location = location?.currentLocation {
                print(location)
            } else {
                print("location not found")
            }
        })
    }

    class func askForLogin(on vc: UIViewController, completion: (()->Void)?) {
        let story = UIStoryboard.init(name: "Welcome", bundle: nil)
        if let navLogin = story.instantiateViewController(withIdentifier: "navLogin") as? UINavigationController,
            let loginVC = navLogin.viewControllers.first as? LoginVC {
            loginVC.loginCompletion = completion
            vc.present(navLogin, animated: true, completion: {

            })
        }
    }

    func login() {
        self.txtEmail.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        if let emailText = self.txtEmail.text,
            emailText.isValidEmail() {
            if let passText = self.txtPassword.text,
                !passText.isEmpty {
                self.attemptLogin(withEmail: emailText, password: passText)
            } else {
                self.showAlert("Required".localized, message: "Password cannot be blank".localized)
                self.txtPassword.becomeFirstResponder()
            }
        } else {
            self.showAlert("Required".localized, message: "Please enter valid email address".localized)
            self.txtEmail.becomeFirstResponder()
        }
    }

    func attemptLogin(withEmail email: String, password: String) {
        func proceedFurther(with user: RMUser) {
            self.hideLoader()
            if user.isSignupComplete {
                self.loginFinished()
            } else {
                self.performSegue(withIdentifier: "segueRegistrationNameVC", sender: nil)
            }
        }
        self.showLoader()
        APIManager.shared.loginUser(with: email, password: password, { (user, success, error) in
            if let user = user {
                if let location = self.userlocation.currentLocation {
//                    APIManager.shared.updateLocation(at: location.latitude, longitude: location.longitude, { (success) in
                        proceedFurther(with: user)
//                    })
                } else {
                    proceedFurther(with: user)
                }
            } else {
                self.hideLoader()
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    self.showAlert("Error".localized, message: "Login failed!".localized)
                }
                RMLoginSession.clearLocalSession()
                self.txtPassword.becomeFirstResponder()
            }
        })
    }

    func loginFinished() {
        Analytics.shared.track(category: "User_login", action: "login", label: "login")
        if let del = UIApplication.shared.delegate as? AppDelegate {
            del.registerForNotifcation()
        }
        APIManager.shared.getDefaultOfficeSearchFilter()
        self.navigationController?.dismiss(animated: true, completion: {
            self.loginCompletion?()
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail {
            self.txtPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.login()
        }
        return true
    }

}

