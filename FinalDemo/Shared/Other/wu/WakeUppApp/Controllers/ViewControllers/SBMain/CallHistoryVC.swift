//
//  CallHistoryVC.swift
//  WakeUppApp
//
//  Created by Admin on 13/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

//nilesh
class CallHistoryCell: UITableViewCell {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var imgType: UIImageView!
    
    @IBOutlet var btnReCall: UIButton!
}

class CallHistoryVC: UIViewController {
    
    @IBOutlet var btnMore: UIButton!
    @IBOutlet weak var vwnodata: UIView!
    @IBOutlet var tblCallHistory: UITableView!
    @IBOutlet weak var vwdetailcall: UIView!
    @IBOutlet weak var imguserprofile: UIImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblcalldetails: UILabel!
    
    var arrCallHistory = [StructCallHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arrCallHistory = CoreDBManager.sharedDatabase.getCallHistory() as! [StructCallHistory]
        self.tblCallHistory.tableFooterView = UIView()
        setUpViews()
        self.tblCallHistory.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreOptionAction(_ sender: UIButton) {
        let arrMenus = ["Clear"]
        openDropDown(From : sender, with: arrMenus, completion: { selectedMenuIndex in
            switch selectedMenuIndex {
            case 0:
                CoreDBManager.sharedDatabase.deleteAllCallHistoryFromLocalDB()
                self.arrCallHistory.removeAll()
                self.tblCallHistory.reloadData()
                self.setUpViews()
                break
            default:
                break
            }
        })
    }
  
    //MARK: - Manage
    func saveCallInLocalDB(isVideoCall:String, obj : StructCallHistory) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dictCall = [
            "image":"\(obj.image)",
            "name":obj.name,
            "status":"outgoing",
            "is_video_call":isVideoCall,
            "call_from":"From chat call",
            "call_to":obj.call_to,
            "call_id":appDelegate.getUniquieNo(),
            "date":appDelegate.getCurrentTime(),
            ]  as [String : Any]
        
        appDelegate.storeCallLog(dictCall: dictCall)
    }
    
    func manage_Calling_Video(obj : StructCallHistory, UserInfo:StructChat) {
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVideoCallVC) as! VideoCallVC
        vc.userID = UserInfo.kuserid
        vc.userName = UserInfo.kusername
        vc.userPhoto = UserInfo.kuserprofile
        vc.isReceivedCall = false
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    func manage_Calling_Audio(obj : StructCallHistory, UserInfo:StructChat) {
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVoiceCallVC) as! VoiceCallVC
        vc.userID = UserInfo.kuserid
        vc.userName = UserInfo.kusername
        vc.userPhoto = UserInfo.kuserprofile
        vc.userMobile = UserInfo.kphonenumber
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    @IBAction func btnofdetailsclicked(_ sender: UIButton)
    {
        self.vwdetailcall.isHidden = true
        let objCall : StructCallHistory = arrCallHistory[self.vwdetailcall.tag]
        let objUserInfo : StructChat = CoreDBManager.sharedDatabase.getFriendInfoByPhoneNo(userPhoneNo:objCall.call_to)!
       
        switch sender.tag {
        case 100:
            CoreDBManager.sharedDatabase.deleteSingleCallHistory(callID: objCall.call_id)
            arrCallHistory.remove(at: self.vwdetailcall.tag)
            setUpViews()
            if arrCallHistory.count > 0 {
                self.tblCallHistory.beginUpdates()
                self.tblCallHistory.deleteRows(at: [IndexPath.init(row: self.vwdetailcall.tag, section: 0)], with: .none)
                self.tblCallHistory.endUpdates()
            } else {
                self.tblCallHistory.reloadData()
            }
            break
        case 200:
             if objUserInfo.kphonenumber.count > 0 {
            self.saveCallInLocalDB(isVideoCall: "1", obj: objCall)
            self.manage_Calling_Video(obj: objCall, UserInfo: objUserInfo)
             }
            break
        case 300:
             if objUserInfo.kphonenumber.count > 0 {
            self.saveCallInLocalDB(isVideoCall: "0", obj: objCall)
            self.manage_Calling_Audio(obj: objCall, UserInfo: objUserInfo)
             }
            break
        default:
            break
        }
    }
    @IBAction func btncloseclicked(_ sender: Any)
    {
        self.vwdetailcall.alpha = 1
        UIView.animate(withDuration: 0.6, animations: {
            self.vwdetailcall.alpha = 0
            self.vwdetailcall.isHidden = false
        })
    }
}

extension CallHistoryVC:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tblCallHistory.isHidden = true
        self.vwnodata.isHidden = true
        
        if arrCallHistory.count == 0 {
            self.vwnodata.isHidden = false
            return 0
        }
        else {
            self.tblCallHistory.isHidden = false
            return arrCallHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistoryCell") as! CallHistoryCell
        let objCall = arrCallHistory[indexPath.row]
        if verifyUrl(urlString: objCall.image) {
            cell.imgProfile.sd_setImage(with: objCall.image.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: nil)
        } else {
            cell.imgProfile.image = UserPlaceholder
        }
        
        cell.lblName.text = objCall.name
        if objCall.is_video_call == "1" {
            cell.imgType.image = UIImage(named:"video_call_sm")
        } else {
            cell.imgType.image = UIImage(named:"voice_call_sm")
        }
        
        cell.btnReCall.tag = indexPath.row
        cell.btnReCall.addTarget(self, action: #selector(btnReCallAction(_:)), for: .touchUpInside)
        cell.btnReCall.setImage(UIImage(named: ""), for: .normal)
        if objCall.is_video_call == "1" {
            cell.btnReCall.setImage(UIImage(named: "icon_Call_Video_Green"), for: .normal)
        } else {
            cell.btnReCall.setImage(UIImage(named: "icon_Call_Audio_Green"), for: .normal)
        }
        
        cell.lblStatus.text = TRIM(string: objCall.status)
        cell.lblStatus.text = "\(TRIM(string: objCall.status)) | \(objCall.date)"
        //cell.lblTime.text = objCall.date
        cell.lblTime.text = ""
        
        cell.lblName.textColor = UIColor.black
        if objCall.status == "missed" { cell.lblName.textColor = UIColor.red }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let objCall = arrCallHistory[indexPath.row]
            CoreDBManager.sharedDatabase.deleteSingleCallHistory(callID: objCall.call_id)
            arrCallHistory.remove(at: indexPath.row)
            setUpViews()
            if arrCallHistory.count > 0 {
                self.tblCallHistory.beginUpdates()
                self.tblCallHistory.deleteRows(at: [indexPath], with: .none)
                self.tblCallHistory.endUpdates()
            } else {
                self.tblCallHistory.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let objCall = arrCallHistory[indexPath.row]
        if verifyUrl(urlString: objCall.image) {
            self.imguserprofile.sd_setImage(with: objCall.image.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: nil)
        } else {
            self.imguserprofile.image = UserPlaceholder
        }
        self.lblname.text = objCall.name
        self.lblcalldetails.text = "\(TRIM(string: objCall.status)) | \(objCall.date)"
        if objCall.status == "missed" { self.lblname.textColor = UIColor.red }
        else { self.lblname.textColor = UIColor.black}
        
        self.vwdetailcall.alpha = 0.2
        self.vwdetailcall.isHidden = false
        UIView.animate(withDuration: 0.6, animations: {
            self.vwdetailcall.tag = indexPath.row
            self.vwdetailcall.alpha = 1
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK : Button action
    @objc func btnReCallAction(_ sender: UIButton) {
        let objCall : StructCallHistory = arrCallHistory[sender.tag]
        
        let objUserInfo : StructChat = CoreDBManager.sharedDatabase.getFriendInfoByPhoneNo(userPhoneNo:objCall.call_to)!
        if objUserInfo.kphonenumber.count > 0 {
            if objCall.is_video_call == "1" {
                //showMessage("Video Call")
                self.saveCallInLocalDB(isVideoCall: "1", obj: objCall)
                self.manage_Calling_Video(obj: objCall, UserInfo: objUserInfo)
            }
            else {
                //showMessage("Audio Call")
                self.saveCallInLocalDB(isVideoCall: "0", obj: objCall)
                self.manage_Calling_Audio(obj: objCall, UserInfo: objUserInfo)
            }
        }
        else {
            showMessage(SomethingWrongMessage)
        }
    }
}

extension CallHistoryVC {
    func setUpViews() {
        if arrCallHistory.count == 0 {
            self.vwnodata.isHidden = false
            self.btnMore.isHidden = true
        } else {
            self.vwnodata.isHidden = true
            self.btnMore.isHidden = false
        }
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}

