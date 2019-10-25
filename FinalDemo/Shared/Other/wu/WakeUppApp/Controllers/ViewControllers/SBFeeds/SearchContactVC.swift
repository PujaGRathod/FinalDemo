//
//  SearchContactVC.swift
//  WakeUppApp
//
//  Created by C025 on 21/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchContactVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet var tblContact: UITableView!
    
    @IBOutlet weak var viewPlaceHolder: UIView!
    @IBOutlet weak var lblPlaceholder_Title: UILabel!
    @IBOutlet weak var lblPlaceholder_SubTitle: UILabel!
    
    //MARK:- Variable
    var arrContact = [Searching_Contact]() // For use store Search contact data, getting by WebService.
    var selectedContact : IndexPath! // For user detect curret selected channel cell
    var offset : Int = 0 // Manage LoadMore in Channel List.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        runAfterTime(time: 0.25) {
            self.txtSearch.becomeFirstResponder()
        }
        
        self.tblContact.delegate = self
        self.tblContact.dataSource = self
        offset = 0
        self.textFieldDidChange(txtSearch) 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textFieldDidChange(self.txtSearch)
    }
    
    //MARK:- Custom Methods
    @objc func textFieldDidChange(_ textField: UITextField) {
        let strText : String = TRIM(string: textField.text!)
        if (strText.count != 0) {
            self.api_SearchContact()
        }
        else {
            self.arrContact.removeAll()
            
            lblPlaceholder_Title.text = "Looks like you have to seen the searching contact results."
            lblPlaceholder_SubTitle.text = ""
        }
        self.tblContact.reloadData()
    }
    
    //MARK:- Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    // MARK: - Tableview Delegate Method
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noOfRow: Int = arrContact.count
        
        
        viewPlaceHolder.isHidden = true
        tblContact.isHidden = true
        if (noOfRow == 0) {
            viewPlaceHolder.isHidden = false
        }
        else {
            tblContact.isHidden = false
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchContactCell = tableView.dequeueReusableCell(withIdentifier: "SearchContactCell") as! SearchContactCell
        
        let objContact = arrContact[indexPath.row]
        
        cell.imgUser.sd_setImage(with: URL.init(string: objContact.imagePath!), placeholderImage: #imageLiteral(resourceName: "profile_pic_register"))
        cell.lblName.text = objContact.fullName!
        cell.lblUsername.text = objContact.username
        
        cell.btnFollow.cornerRadius = cell.btnFollow.height/2
        cell.btnFollow.tag = indexPath.row
        cell.btnFollow.addTarget(self, action: #selector(Manage_Contact_FollowOption(sender:)), for: .touchUpInside)
        //Set Title
        cell.btnFollow.backgroundColor = UIColor.lightGray
        if (objContact.isFollowing == true) {
            cell.btnFollow.setTitle("Following", for: .normal)
            cell.btnFollow.setBackgroundImage(UIImage.init(), for: .normal)
        }
        else {
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.setBackgroundImage(#imageLiteral(resourceName: "ic_gradient"), for: .normal)
        }
        
        tableView.allowsSelection = true
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objContact = arrContact[indexPath.row]
        
        let objVC : OtherProfileVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idOtherProfileVC) as! OtherProfileVC
        objVC.strViewProfile_UserID = objContact.userId!
        objVC.strUser_ProfilePhoto = objContact.imagePath!
        objVC.strUser_FullName = objContact.fullName!
        objVC.flag_UserFollow = objContact.isFollowing!
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    //MARK: Tableview button action method
    @objc func Manage_Contact_FollowOption(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedContact = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedContact = arrContact[selectedContact.row]
        
        var strUserFollowStatus : NSString = "follow"
        strUserFollowStatus = objSelectedContact.isFollowing == true ? "unfollow" : strUserFollowStatus
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIUserFollow,
                                      "request":["follow_to":objSelectedContact.userId!,
                                                 "action":strUserFollowStatus],
                                      "auth" : getAuthForService()]
        self.api_userFollow(parameter: parameter)
        
        
        //Changes Button of Selected Object
        objSelectedContact.isFollowing = objSelectedContact.isFollowing == true  ? false : true //Uppdate Obj Flag
        self.arrContact.remove(at: selectedContact.row) //Remove Old Obj
        self.arrContact.insert(objSelectedContact, at: selectedContact.row) //Added Updated Obj
        self.tblContact.reloadRows(at: [self.selectedContact], with: .fade) //Reload Cell
    }
    
    //MARK:- API
    func api_SearchContact() {
        //API - 66 (searching)
        //Note : action : channel / contact
        let strText : String = TRIM(string: txtSearch.text!)
        let parameter:NSDictionary = ["service":APISearching_Contact,
                                      "request":["search":strText,
                                                 "search_type":"contact",
                                                 "offset":offset],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISearching_Contact, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_SearchContact()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        let arrData : NSArray = dicRespo.value(forKey: "contacts") as! NSArray
                        if arrData.count > 0 {
                            let arrMutData = NSMutableArray()
                            for jsondata in arrData {
                                let j = JSON(jsondata)
                                let objData:Searching_Contact = Searching_Contact.init(json: j)
                                arrMutData.add(objData)
                            }
                            
                            self.arrContact.removeAll()
                            self.arrContact = arrMutData as! [Searching_Contact]
                        }
                        else {
                            //showMessage(statusmessage)
                            
                            self.lblPlaceholder_Title.text = "Looks like you have no contact results for '\(TRIM(string: self.txtSearch.text!))'"
                            self.lblPlaceholder_SubTitle.text = "Try a different keyword"
                        }
                        self.tblContact.reloadData()
                    }
                }
            }
        })
    }
    
    func api_userFollow(parameter : NSDictionary) {
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_userFollow(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Show Success message
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                }
            }
        })
    }
    
}

