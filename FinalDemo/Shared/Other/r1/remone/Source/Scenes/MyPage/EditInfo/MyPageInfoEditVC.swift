//
//  MyPageInfoEditVC.swift
//  remone
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
//import IQKeyboardManagerSwift

struct EditProfileDetailsModel {
    
    var name: String = ""
    var ruby: String = ""
    var userInfo: String = ""
    var position: RMPosition?
    var department: RMDepartment?
    
    init(name: String, ruby: String, userInfo: String, department: RMDepartment?, position: RMPosition?) {
        self.name = name
        self.ruby = ruby
        self.userInfo = userInfo
        self.department = department
        self.position = position
    }

    func getParamData() -> [String:Any] {
        var paramDic:[String:Any] = [:]
        if self.name.trimString() != "" {
            paramDic["name"] = self.name
        }

        if self.ruby.trimString() != "" {
            paramDic["ruby"] = self.ruby
        }

        if self.userInfo.trimString() != "" {
            paramDic["info"] = self.userInfo
        }

        if let dept = self.department {
            paramDic["departmentId"] = dept.id
        }

        if let pos = self.position {
            paramDic["positionId"] = pos.id
        }

        return paramDic
    }
    
}

class MyPageInfoEditVC: UITableViewController {

    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnCompleted: UIBarButtonItem!
    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var lblRuby: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblDepartment: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var txtViewUserInfo: UITextView!

    var dataModel: EditProfileDetailsModel!
    var reloadProfile: UserProfileReload?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reset()
        self.txtViewUserInfo.delegate = self
        self.tableView.shouldRestoreScrollViewContentOffset = true
//        self.txtViewUserInfo.shouldRestoreScrollViewContentOffset = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "My Page Inforation Edit")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reset() {
        if let user = APIManager.shared.loginSession?.user {
            self.lblName.text = user.name
//            self.lblRuby.text = user.ruby
            self.lblCompany.text = user.company?.name
            self.lblPosition.text = user.position?.name
            self.lblDepartment.text = user.department?.name
            self.txtViewUserInfo.text = user.info
            self.dataModel = EditProfileDetailsModel(name: user.name,
                                                     ruby: user.ruby,
                                                     userInfo: user.info,
                                                     department: user.department,
                                                     position: user.position)
            self.readjustHeight()
            self.tableView.reloadData()
        } else {
            self.navigationController?.dismiss(animated: true, completion: {

            })
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView){
//        arg.translatesAutoresizingMaskIntoConstraints = true
            arg.sizeToFit()
//        arg.isScrollEnabled = false
    }
    
    func readjustHeight() {
        let footerView = self.tableView.tableFooterView
//        let height = self.txtViewUserInfo.text.height(withConstrainedWidth:32, font: self.txtViewUserInfo.font!)
        adjustUITextViewHeight(arg: self.txtViewUserInfo)
        footerView?.frame.size.height = self.txtViewUserInfo.frame.size.height + 38
        self.tableView.tableFooterView = footerView
    }

    func setData(selectedIndex: Int, editedText: String, strId: String) {
        switch selectedIndex {
        case 0:
            self.lblName.text = editedText
            self.dataModel.name = editedText

//        case 1:
//            self.lblRuby.text = editedText
//            self.dataModel.ruby = editedText

        default:
            break
        }
    }

    func setPosition(_ newPosition: RMPosition) {
        self.dataModel.position = newPosition
        self.lblPosition.text = newPosition.name
    }

    func setDepartment(_ newDepartment: RMDepartment) {
        self.dataModel.department = newDepartment
        self.lblDepartment.text = newDepartment.name
    }

    func validateProfileDetail() -> String {
        var strMessage = ""
        if self.lblName.text?.trimString() == "" {
            strMessage = "Please enter name".localized
        }
//        else if self.lblRuby.text?.trimString() == "" {
//            strMessage = "Please enter ruby".localized
//        }
//        else if self.lblPosition.text?.trimString() == "" {
//            strMessage = "Please select any position".localized
//        }
        return strMessage
    }

    @IBAction func onCancelClick(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func onCompletedClick(_ sender: UIBarButtonItem) {
        self.dataModel.userInfo = self.txtViewUserInfo.text.trimString()
        let errorText = self.validateProfileDetail().trimString()
        if  errorText != "" {
            self.showAlert("Required!".localized, message: errorText)
        } else {
            self.showLoader()
            APIManager.shared.updateUserProfileDetail(with: self.dataModel.getParamData(), completion: { (error) in
                self.hideLoader()
                if error != nil {
                    self.showAlert("Error".localized, message: error?.localizedDescription)
                } else {
                    APIManager.shared.loginSession?.user.name = self.dataModel.name
                    APIManager.shared.loginSession?.user.ruby = self.dataModel.ruby
                    APIManager.shared.loginSession?.user.position = self.dataModel.position
                    APIManager.shared.loginSession?.user.department = self.dataModel.department
                    APIManager.shared.loginSession?.user.info = self.dataModel.userInfo
                    APIManager.shared.loginSession?.save()
                    self.reloadProfile?()
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "SegueShowEditDetailTFVC", sender:(indexPath.row,
                                                                                 "名前",
                                                                                 self.dataModel.name))
//        case 1:
//            self.performSegue(withIdentifier: "SegueShowEditDetailTFVC", sender: (indexPath.row,
//                                                                                 "フリカナ",
//                                                                                 self.dataModel.ruby))
        case 1:
            self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.position)

        case 2:
            self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.department)
            break
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row  == 4 {
//            let height = self.txtViewUserInfo.text.height(withConstrainedWidth: 32, font: self.txtViewUserInfo.font!) + 31
//            return height
//        } else {
            return UITableViewAutomaticDimension
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == 4 {
//            cell.separatorInset = UIEdgeInsetsMake(0, tableView.frame.width + 500, 0, 0)
//        }
//    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SegueShowEditDetailTFVC" {
            if let editDetailTFVC = segue.destination as? EditDetailTFVC {
                if let data = sender as? (Int, String, String) {
                    editDetailTFVC.data = data
                    editDetailTFVC.onBackClick = self.setData
                }
            }
        } else if segue.identifier == "segueShowSelectPositionVC"{
            if let selectPositionVc = segue.destination as? SelectPositionVC {
                if let mode = sender as? SelectPositionVC.SelectionMode {
                    selectPositionVc.selectionMode = mode
                    if mode == .position {
                        selectPositionVc.title = "Position".localized
                        selectPositionVc.selectedPosition = self.dataModel.position
                        selectPositionVc.backPositionClosure = { (position) in
                            if let position = position {
                                self.setPosition(position)
                            }
                        }
                    } else {
                        selectPositionVc.title = "Department".localized
                        selectPositionVc.selectedDepartment = self.dataModel.department
                        selectPositionVc.backDepartmentClosure = { (dept) in
                            if let dept = dept {
                                self.setDepartment(dept)
                            }
                        }
                    }
                }
            }
        }
    }

}

extension MyPageInfoEditVC : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.isScrollEnabled == false {
            textView.isScrollEnabled = true
        }
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.isScrollEnabled = true
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.dataModel.userInfo = textView.text
        textView.isScrollEnabled = false
        self.readjustHeight()
        self.tableView.reloadData()
    }
}
