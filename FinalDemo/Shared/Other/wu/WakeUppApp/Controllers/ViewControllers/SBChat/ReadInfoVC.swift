//
//  ReadInfoVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 25/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

enum enumReadInfo : Int {
    case None = 0
    case ReadInfo_PersonalChat
    case ReadInfo_GroupChat
}

class ReadInfoVC: UIViewController {

    @IBOutlet var tblInfo: UITableView!
    
    //MARK:- Variable
    var arrinfo = [StructReadInfo]()
    var arrRead = [StructReadInfo]()
    var arrReceived = [StructReadInfo]()
    var selectedgid = String()
    
    var arrinfo_personalChat = [StructReadInfo_PersonalChat]()
    var arrRead_personalChat = [StructReadInfo_PersonalChat]()
    var arrReceived_personalChat = [StructReadInfo_PersonalChat]()
    var selectedChatID = String()
    
    var objEnumReadInfo : enumReadInfo = .None //For manage what web API Called, get value in Privious VC
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblInfo.delegate = self
        tblInfo.dataSource = self
        tblInfo.tableFooterView = UIView()
        
        self.set_NotificationObserver()
        //self.getGroupReadInfo()
        
        switch objEnumReadInfo {
        case .None:
            self.tblInfo.reloadData()
            break
        
        case .ReadInfo_GroupChat:
            self.getGroupReadInfo()
            break
        
        case .ReadInfo_PersonalChat:
            self.get_ChatReadInfo()
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnbackclicked(_ sender: Any) {
        _ = APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_ReadInfoVC), object: nil)
    }
    
    //MARK: NotificationObserver Method
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_ReadInfoVC) {
            self.tblInfo.reloadData()
        }
    }
}

extension ReadInfoVC {
    func getGroupReadInfo() {
        showHUD()
        let msgDictionary = ["groupchatid" : selectedgid] as [String:Any]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGetGroupMessageReadInfo,msgDictionary).timingOut(after: 30)
        {data in
            //print("keyGetGroupMessageReadInfo : \(data)")
            
            hideHUD()
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                let dic = data[0] as! NSArray
                let obj = dic
                //groupchatid,p.receivetime,p.readtime,p.userid,z.username,z.image
                for dicData in obj {
                    let objData:StructReadInfo = StructReadInfo.init(dictionary: dicData as! [String : Any])
                    self.arrinfo.append(objData)
                }
            }
            
            if self.arrinfo.count > 0 {
                self.arrRead = self.arrinfo.filter({$0.readtime != "-"})
                self.arrReceived = self.arrinfo.filter({$0.readtime == "-"})
            }
            self.tblInfo.reloadData()
        }
    }
    
    func get_ChatReadInfo() {
        showHUD()
        let msgDictionary = [ "chatid" : selectedChatID] as [String:Any]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGetChatMessageReadInfo,msgDictionary).timingOut(after: 30)
        {data in
            //print("keyGetChatMessageReadInfo : \(data)")
            hideHUD()
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                let dic = data[0] as! NSArray
                let obj = dic
                
                for dicData in obj {
                    let objData:StructReadInfo_PersonalChat = StructReadInfo_PersonalChat.init(dictionary: dicData as! [String : Any])
                    self.arrinfo_personalChat.append(objData)
                }
            }
            //print("arrinfo_personalChat: \(self.arrinfo_personalChat)")
            
            if self.arrinfo_personalChat.count > 0{
                //self.arrRead_personalChat = self.arrinfo_personalChat.filter({$0.readtime != "-"})
                //self.arrReceived_personalChat = self.arrinfo_personalChat.filter({$0.readtime == "-"})
                
                self.arrRead_personalChat = [self.arrinfo_personalChat.first!]
                self.arrReceived_personalChat = [self.arrinfo_personalChat.first!]
            }
            self.tblInfo.reloadData()
        }
    }
}

extension ReadInfoVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch objEnumReadInfo {
        case .None:
            return ""
            
        case .ReadInfo_GroupChat:
            switch section {
            case 0:
                return "Seen By"
            default:
                return "Delivered To"
            }
            
        case .ReadInfo_PersonalChat:
            switch section {
            case 0:
                return "Read"
            default:
                return "Delivered"
            }
        }
        //return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch objEnumReadInfo {
        case .None:
            return 0
    
        case .ReadInfo_GroupChat:
            switch indexPath.section {
            case 0:
                return 100
            default:
                return 80
            }
        
        case .ReadInfo_PersonalChat:
            /*switch indexPath.section {
            case 0:
                return 100
            default:
                return 80
            }*/
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch objEnumReadInfo {
        case .None:
            return 0
            
        case .ReadInfo_GroupChat:
            switch section {
            case 0:
                return arrRead.count
            default:
                return arrReceived.count
            }
            
        case .ReadInfo_PersonalChat:
            switch section {
            case 0:
                return arrRead_personalChat.count
            default:
                return arrReceived_personalChat.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch objEnumReadInfo {
        case .None:
            return UITableViewCell.init()
        
        case .ReadInfo_GroupChat:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReadInfoCell") as! ReadInfoCell
                let obj = arrRead[indexPath.row];
                
                if (Privacy_ProfilePhoto_Show(userID: obj.userid) == true) {
                    cell.imgpic.sd_setImage(with: obj.image.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder) { (img, err, type, url) in
                        if err != nil { cell.imgpic.image = UserPlaceholder }
                    }
                } else { cell.imgpic.image = UserPlaceholder }
                
                let strReadReceipts : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ReadReceipts)
                var strReadTime = "-"
                if strReadReceipts == "1" { strReadTime = obj.readtime }
                cell.lblreadtime.text = strReadTime
                
                cell.lblreceivetime.text = obj.receivetime
                
                //cell.lblname.text = obj.username
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode, phoneNo: obj.phoneno)
                if objContactInfo.Name?.count == 0 { cell.lblname.text = "+\(obj.countrycode) \(obj.phoneno)" }
                else { cell.lblname.text = objContactInfo.Name ?? obj.username }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedInfoCell") as! ReceivedInfoCell
                let obj = arrReceived[indexPath.row];
                
                if (Privacy_ProfilePhoto_Show(userID: obj.userid) == true) {
                    cell.imgpic.sd_setImage(with: obj.image.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder) { (img, err, type, url) in
                        if err != nil { cell.imgpic.image = UserPlaceholder }
                    }
                } else { cell.imgpic.image = UserPlaceholder }
                
                cell.lblreceivedtime.text = obj.receivetime
                
                //cell.lblname.text = obj.username
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode, phoneNo: obj.phoneno)
                if objContactInfo.Name?.count == 0 { cell.lblname.text = "+\(obj.countrycode) \(obj.phoneno)" }
                else { cell.lblname.text = objContactInfo.Name ?? obj.username }
                
                return cell
            }
            
        case .ReadInfo_PersonalChat:
            switch indexPath.section {
            case 0:
                let cell : UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
                cell.cornerRadius = 5
                
                let obj = arrRead_personalChat[indexPath.row];
                cell.textLabel?.text = obj.readtime
                
                return cell
            default:
                let cell : UITableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
                cell.cornerRadius = 5
                
                let obj = arrRead_personalChat[indexPath.row];
                cell.textLabel?.text = obj.receivetime
                
                return cell
            }
        }
    }
}
