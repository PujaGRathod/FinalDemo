//
//  DeleteMyAccountVC.swift
//  WakeUppApp
//
//  Created by C025 on 15/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class DeleteMyAccountVC: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var lblDeleteAccTitle: UILabel!
    @IBOutlet weak var lblDeleteAccMess: UILabel!
    
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var txtMobileNo: UITextField!
    
    //MARK: Variable
    var countyCode = "91"
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom function
    func setupUI() {
        self.view.disableKeybordWhenTapped = true
        
        var strTitle : String = ""
        strTitle += "Deleting your account will:".uppercased()
        
        var strMess : String = ""
        strMess += "- Delete your account from \(APPNAME)"
        strMess += "\n- Erase your message history"
        strMess += "\n- Delete you from all of your \(APPNAME) groups"
        strMess += "\n- Delete your Backup"
        strMess += "\n- Delete your all post records"
        strMess += "\n- Delete your all channel and it's video"
        
        lblDeleteAccTitle.text = strTitle
        lblDeleteAccMess.text = strMess
        lblDeleteAccMess.numberOfLines = 0
        
        txtCountryCode.addPaddingLeftIcon(UIImage.init(named: "countrycode_textbox")!, padding: 15)
        txtMobileNo.addPaddingLeftIcon(UIImage.init(named: "mobile_textbox")!, padding: 15)
        
        txtCountryCode.delegate = self
        txtMobileNo.delegate = self
        
        txtCountryCode.text = "India (+91)"
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnChangeAccNoAction() {
        let objVC : ChangeNumberVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idChangeNumberVC) as! ChangeNumberVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnDeleteAccountAction() {
        
        if let txtMobile = txtMobileNo.text{
            if txtMobile != UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile){
                showMessage("Enter correct mobile number")
                return
            }
        }
        
        
        let alert = UIAlertController.init(title: nil, message: "Are you sure to delete your account?", preferredStyle: .alert)
        
        let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
        
        let actionYes = UIAlertAction.init(title: "Yes", style: .destructive) { (action) in
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("DeleteAccount",["user_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)]).timingOut(after: 1)
            {data in
                let data = data as Array
                if(data.count > 0)
                {
                    if data[0] is String{
                        return
                    }
                    print(data)
                    
                    APP_DELEGATE.appNavigation = UINavigationController(rootViewController: loadVC(strStoryboardId: SB_MAIN, strVCId: idLoginVC))
                    APP_DELEGATE.appNavigation?.isNavigationBarHidden = true
                    APP_DELEGATE.window?.rootViewController = APP_DELEGATE.appNavigation
                    
                    UserDefaultManager.clearUserdefaullts()
                }
            }
        }
        
        alert.addAction(actionNo)
        alert.addAction(actionYes)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension DeleteMyAccountVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtCountryCode {
            self.view.endEditing(true)
            let countyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idCountrypickerVC) as! SRCountryPickerController
            countyvc.countryDelegate = self
            APP_DELEGATE.appNavigation?.pushViewController(countyvc, animated: true)
            return false
        }
        return true
    }
}

extension DeleteMyAccountVC: CountrySelectedDelegate {
    func SRcountrySelected(countrySelected country: Country) {
        self.txtCountryCode.text = country.country_name + " (" + country.dial_code + ")"
        self.countyCode = country.dial_code
    }
}
