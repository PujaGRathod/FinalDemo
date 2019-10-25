//
//  ChannelNotificationVC.swift
//  WakeUppApp
//
//  Created by C025 on 04/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelNotificationVC: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    
    @IBOutlet weak var tblNotification: UITableView!
    var dictNotification : NSMutableDictionary = NSMutableDictionary()
    
    @IBOutlet weak var viewPlaceHolder: UIView!
    @IBOutlet weak var lblPlaceholder_Title: UILabel!
    @IBOutlet weak var lblPlaceholder_SubTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblNotification.delegate  = self
        tblNotification.dataSource = self
        tblNotification.estimatedRowHeight = 65
        tblNotification.rowHeight = UITableViewAutomaticDimension
        
        lblPlaceholder_Title.text = "Looks like you have to see your notification."
        lblPlaceholder_SubTitle.text = "When you see someone follows you, likes, comment or any activity for your account."
        
        self.api_GetAllNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    // MARK: - Table View Delegate Method
    func numberOfSections(in tableView: UITableView) -> Int {
        let arrSection = dictNotification.allKeys as NSArray
        let noOfSection: Int = arrSection.count
        
        viewPlaceHolder.isHidden = true
        tblNotification.isHidden = true
        if (noOfSection == 0) { viewPlaceHolder.isHidden = false }
        else { tblNotification.isHidden = false }
        
        return noOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arrSection = dictNotification.allKeys as NSArray
        let strKey = arrSection.object(at: section)
        let arrRows = dictNotification.object(forKey: strKey) as! NSArray
        return arrRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let arrSection = dictNotification.allKeys as NSArray
        let strHeaderTitle = arrSection.object(at: section) as! String
        
        let headerView = UIView()
        headerView.frame = CGRect.init(x: 0, y: 0, width: SCREENWIDTH(), height: 34)
        headerView.backgroundColor = RGBA(249, 245, 242, 1)
        
        let lblTitle = UILabel()
        lblTitle.frame = CGRect.init(x: 10, y: 0, width: SCREENWIDTH() - 10.0, height: 34)
        lblTitle.font = FontWithSize(FT_Medium, 13)
        lblTitle.textColor = UIColor.darkGray
        lblTitle.text = strHeaderTitle.uppercased()
        headerView.addSubview(lblTitle)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblNotification.dequeueReusableCell(withIdentifier: "ChannelNotificationCell") as! ChannelNotificationCell
        
        var strPhotoURL : String = ""
        var strComment : String = ""
        var strDateTime : String = ""
        
        let arrSection = dictNotification.allKeys as NSArray
        let strKey = arrSection.object(at: indexPath.section)
        let arrData = dictNotification.object(forKey: strKey) as! NSArray
        let dictData : NSDictionary = arrData.object(at: indexPath.row) as! NSDictionary
        
        strPhotoURL = dictData.object(forKey: "profile_img") as! String
        strComment = dictData.object(forKey: "text") as! String
        strDateTime = dictData.object(forKey: "creation_datetime") as! String
        
        //Image
        cell.imgProfile.sd_setImage(with: URL.init(string: strPhotoURL), placeholderImage: ProfilePlaceholderImage)
        cell.imgProfile.cornerRadius = cell.imgProfile.height/2
        
        //Noti. Mess
        cell.lblNotification.text = strComment
        cell.lblNotification.numberOfLines = 0
        //cell.lblNotification.sizeToFit()
        
        //Time
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strDateTime) as Date
        strDateTime = timeAgoSinceDate(date: date, numericDates: false)
        cell.lblTime.text = strDateTime
        
        //Button
        cell.btnFollow.isHidden = true //Hide Follow Button
        cell.btnFollow.cornerRadius = cell.btnFollow.height/2
        
        cell.selectionStyle = .none
        return cell;
    }
    
    //MARK:- API
    func api_GetAllNotification() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetAllNotification,
                                      "request":[:],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetAllNotification, parameters: parameter, keyname: "", message: APIGetAllNotificationMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetAllNotification()
                })
                return
            }
            else {
                let dicData : NSMutableDictionary = (responseDict![kData] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                dicData.removeObject(forKey: "new_count")
                
                let arrKeys: NSArray = ["today","yesterday","all"] //dicData.allKeys as NSArray
                for i in 0..<arrKeys.count {
                    let strKey = arrKeys.object(at: i) as! String
                    let arrKey = dicData.object(forKey: strKey) as! NSArray
                    if arrKey.count > 0 {
                        self.dictNotification.setObject(arrKey, forKey: strKey as NSCopying)
                    }
                }
                
                if (self.dictNotification.allKeys.count == 0) {
                    self.lblPlaceholder_Title.text = "You don't have any notifications right now."
                    self.lblPlaceholder_SubTitle.text = "When someone follows you, likes, comment or any activity, you will see it here."
                }
                self.tblNotification.reloadData()
            }
        })
    }
}

