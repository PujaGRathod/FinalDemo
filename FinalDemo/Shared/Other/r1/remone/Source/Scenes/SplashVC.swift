//
//  SplashVC.swift
//  remone
//
//  Created by Arjav Lad on 19/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var splashView: UIView!

    var showSplash: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnStart.alpha = 0
        self.lblWelcome.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Welcome")
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.showSplash {
            self.perform(#selector(self.hideSplah), with: nil, afterDelay: 2)
        } else {
            self.showStartButton()
            self.splashView.isHidden = true
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

    func showStartButton() {
        self.btnStart.layer.cornerRadius = self.btnStart.frame.height / 2
        UIView.animate(withDuration: 0.27) {
            self.btnStart.alpha = 1
            self.lblWelcome.alpha = 1
        }
    }

    @objc func hideSplah() {
        self.showStartButton()
        UIView.animate(withDuration: 0.27, animations: {
            self.splashView.alpha = 0
        }) { _ in
            self.view.sendSubview(toBack: self.splashView)
            self.splashView.isHidden = true
        }
    }

    func askforLogin() {
        LoginVC.askForLogin(on: self, completion: {
            if APIManager.shared.isUserRegistrationComeplete {
                RMLoginSession.setupLoginFlow()
            }
        })
    }

    @IBAction func onStartTap(_ sender: UIButton) {
        if APIManager.shared.isSessionActive {
            if APIManager.shared.isUserRegistrationComeplete {
                self.performSegue(withIdentifier: "segueShowDashboard", sender: nil)
            } else {
                self.askforLogin()
            }
        } else {
            self.askforLogin()
        }
    }

}
