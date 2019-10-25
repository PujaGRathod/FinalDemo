//
//  ChannelSearchVC.swift
//  WakeUppApp
//
//  Created by C025 on 21/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelSearchVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet var tblChannel: UITableView!
    
    @IBOutlet weak var viewPlaceHolder: UIView!
    @IBOutlet weak var lblPlaceholder_Title: UILabel!
    @IBOutlet weak var lblPlaceholder_SubTitle: UILabel!
    
    //MARK:- Variable
    var arrChannel = [Searching_Channel]() // For use store Search Channel data, getting by WebService.
    var selectedChannel : IndexPath! // For user detect curret selected channel cell
    var offset : Int = 0 // Manage LoadMore in Channel List.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        runAfterTime(time: 0.25) {
            self.txtSearch.becomeFirstResponder()
        }
        
        self.tblChannel.delegate = self
        self.tblChannel.dataSource = self
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
            self.api_SearchChannel()
        }
        else {
            self.arrChannel.removeAll()
            lblPlaceholder_Title.text = "Looks like you have to seen the searching channel results."
            lblPlaceholder_SubTitle.text = ""
        }
        self.tblChannel.reloadData()
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
        let noOfRow: Int = arrChannel.count
        
        viewPlaceHolder.isHidden = true
        tblChannel.isHidden = true
        if (noOfRow == 0) {
            viewPlaceHolder.isHidden = false
        }
        else {
            tblChannel.isHidden = false
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ChannelSearchCell = tableView.dequeueReusableCell(withIdentifier: "ChannelSearchCell") as! ChannelSearchCell
        
        let objChannel = arrChannel[indexPath.row]
        
        cell.imgChannel.sd_setImage(with: URL.init(string: objChannel.logo!), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        cell.lblTitle.text = objChannel.title!
        cell.lblDesc.text = objChannel.descriptionValue!
        cell.lblDesc.numberOfLines = 2
        
        cell.btnSubscribe.cornerRadius = cell.btnSubscribe.height/2
        cell.btnSubscribe.tag = indexPath.row
        cell.btnSubscribe.addTarget(self, action: #selector(Manage_Channel_SubscribeOption(sender:)), for: .touchUpInside)
        //Set Title
        cell.btnSubscribe.backgroundColor = UIColor.lightGray
        if (objChannel.isSubscribe == true) {
            cell.btnSubscribe.setTitle("Unsubscribe", for: .normal)
            cell.btnSubscribe.setBackgroundImage(UIImage.init(), for: .normal)
        }
        else {
            cell.btnSubscribe.setTitle("Subscribe", for: .normal)
            cell.btnSubscribe.setBackgroundImage(#imageLiteral(resourceName: "ic_gradient"), for: .normal)
        }
        
        tableView.allowsSelection = true
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChannel = arrChannel[indexPath.row]
        
        let objChannelProVC : ChannelProfileVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelProfileVC) as! ChannelProfileVC
        objChannelProVC.strChannelID = objChannel.id!
        APP_DELEGATE.appNavigation?.pushViewController(objChannelProVC, animated: true)
    }
    
    //MARK: Tableview button action method
    @objc func Manage_Channel_SubscribeOption(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedChannel = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannel = arrChannel[selectedChannel.row]
        
        //Manage Channel Subscribe activity action perform.
        // NOTE :
        // set action - subscribe/unsubscribe | base on API no.-42
        var strChannelSubscribeFlag : NSString = "unsubscribe"
        strChannelSubscribeFlag = objSelectedChannel.isSubscribe == true ? strChannelSubscribeFlag : "subscribe"
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIAddChannelSubscribe,
                                      "request":["channel_id": objSelectedChannel.id!,
                                                 "action": strChannelSubscribeFlag],
                                      "auth" : getAuthForService()]
        self.api_ChannelSubscribe(parameter: parameter)
        
        
        //Changes Button of Selected Object
        objSelectedChannel.isSubscribe = objSelectedChannel.isSubscribe == true ? false : true //Uppdate Obj Flag
        self.arrChannel.remove(at: selectedChannel.row) //Remove Old Obj
        self.arrChannel.insert(objSelectedChannel, at: selectedChannel.row) //Added Updated Obj
        self.tblChannel.reloadRows(at: [self.selectedChannel], with: .fade) //Reload Cell
    }
    
    //MARK:- API
    func api_SearchChannel() {
        //API - 66 (searching)
        //Note : action : channel / contact
        let strText : String = TRIM(string: txtSearch.text!)
        let parameter:NSDictionary = ["service":APISearching_Channel,
                                      "request":["search":strText,
                                                 "search_type":"channel",
                                                 "offset":offset],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISearching_Channel, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_SearchChannel()
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
                        let arrData : NSArray = dicRespo.value(forKey: "channels") as! NSArray
                        if arrData.count > 0 {
                            let arrMutData = NSMutableArray()
                            for jsondata in arrData {
                                let j = JSON(jsondata)
                                let objData:Searching_Channel = Searching_Channel.init(json: j)
                                arrMutData.add(objData)
                            }
                            
                            self.arrChannel.removeAll()
                            self.arrChannel = arrMutData as! [Searching_Channel]
                        }
                        else {
                            //showMessage(statusmessage)
                            self.lblPlaceholder_Title.text = "Looks like you have no channel results for '\(TRIM(string: self.txtSearch.text!))'"
                            self.lblPlaceholder_SubTitle.text = "Try a different keyword"
                        }
                        self.tblChannel.reloadData()
                    }
                }
            }
        })
    }
    
    func api_ChannelSubscribe(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannelSubscribe, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ChannelSubscribe(parameter: parameter)
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

