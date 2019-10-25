//
//  ConfirmEmailVC.swift
//  remone
//
//  Created by Arjav Lad on 02/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class ConfirmEmailVC: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var btnClose: UIBarButtonItem!

    var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.lblMessage.numberOfLines = 0
        self.lblMessage.text = "\(self.email) にメールを送信しました。メールに記載されたリンクをクリックするとパスワードをリセットできます。\n メールが届かない場合、迷惑メールやスパムフォルダーなどもご確認ください。"
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Confirm Email")
        super.viewWillAppear(animated)
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

    @IBAction func btnResend(_ sender: UIButton) {
        self.showLoader()
        APIManager.shared.forgotPassword(for: self.email, completion: { (sucess, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                let success = "A recovery link is sent to given email address.".localized
                self.showAlert("Recovery email sent".localized,
                               message:  "\(success)\n\(self.email).",
                               actionTitle: "ok".localized,
                               actionStyle: .default,
                               actionHandler: { (action) in
                })
            }
        })
    }

    @IBAction func onCloseTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
