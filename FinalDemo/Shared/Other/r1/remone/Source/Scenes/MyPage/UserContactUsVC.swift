
//
//  UserContactUsVC.swift
//  remone
//
//  Created by Arjav Lad on 24/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class UserContactUsVC: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var txtViewDetails: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtViewDetails.becomeFirstResponder()
        self.txtViewDetails.delegate = self
//        self.tableView.shouldRestoreScrollViewContentOffset = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "User contact us")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.tableView.shouldRestoreScrollViewContentOffset = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
        return true
    }

    @IBAction func onSendTap(_ sender: UIBarButtonItem) {
        let contenttext = self.txtViewDetails.text.trimString()
        if contenttext != "" {
            self.txtViewDetails.resignFirstResponder()
            APIManager.shared.contactUs(with: contenttext, { (error) in
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    self.showAlert("Your inquiry has been sent".localized,
                                   message: "Thank you for your inquiry.".localized,
                                   actionHandler: { _ in
                                    self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                }
            })
        } else {
            self.txtViewDetails.text = self.txtViewDetails.text.trimString()
            self.showAlert("Required".localized, message: "Please enter your inquiry".localized)
            self.txtViewDetails.becomeFirstResponder()
        }
    }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.txtViewDetails.resignFirstResponder()
        self.navigationController?.dismiss(animated: true, completion: nil)
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
