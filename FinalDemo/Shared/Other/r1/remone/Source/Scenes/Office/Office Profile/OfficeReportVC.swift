
//
//  OfficeReportVC.swift
//  remone
//
//  Created by Arjav Lad on 20/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class OfficeReportVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var lblOfficeName: UILabel!
    @IBOutlet weak var txtViewReport: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var office: RMOffice!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lblOfficeName.text = self.office.name
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
        self.scrollView.shouldRestoreScrollViewContentOffset = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Office Report")
        self.txtViewReport.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.scrollView.shouldRestoreScrollViewContentOffset = true
        return true
    }

    class func presentOfficeReport(on vc: UIViewController, with office: RMOffice) {
        let storyboard = UIStoryboard.init(name: "OfficeProfile", bundle: nil)
        if let nav = storyboard.instantiateViewController(withIdentifier: "navOfficeReport") as? UINavigationController {
            if let reportVC = nav.viewControllers.first as? OfficeReportVC {
                reportVC.office = office
                vc.present(nav, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onSendTap(_ sender: UIBarButtonItem) {
        let reportText = self.txtViewReport.text.trimString()
        if reportText != "" {
            self.showLoader()
            let params = [
                "id":office.id,
                "details": reportText
                ] as [String : Any]
            APIManager.shared.reportOffice(with: params) { (response,error) in
                self.hideLoader()
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription, actionHandler: { (action) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self.showAlert("Report sent".localized, message: "Thank you for your report.".localized, actionHandler: { (action) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                }
            }
            
        } else {
            self.showAlert("Required".localized, message: "Please enter the content to report".localized, actionHandler: { (action) in
                self.txtViewReport.becomeFirstResponder()
            })
        }
    }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
