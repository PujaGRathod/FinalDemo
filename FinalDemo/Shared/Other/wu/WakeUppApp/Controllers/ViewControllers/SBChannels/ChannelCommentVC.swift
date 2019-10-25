//
//  ChannelCommentVC.swift
//  WakeUppApp
//
//  Created by C025 on 22/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChannelCommentVC: UIViewController {
    
    // MARK: Outlet
    @IBOutlet var inputvalues: Inputbar!
    @IBOutlet var tblcomment: UITableView!
    @IBOutlet var btnback: UIButton!
    
    // MARK: Variable
    //var objSelectedChannelVideo = [GetSingleChannelVideo]() // For use get all video info comment in privious VC
    var strChannelVideoID : String = "0" // For use get particuler video's add comment, This values get in privious VC
    var arrComments_ChannelVideo = [CommentData]() // For use get all video comment in objSelectedChannelVideo object.
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
        super.viewDidAppear(animated)
        self.managekeyboard()
    }
    override func viewDidDisappear(_ animated:Bool)
    {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        self.view.removeKeyboardControl()
    }
    
    // MARK:
    func layoutUI() {
        IQKeyboardManager.shared.enable = false
        self.tblcomment.delegate = self
        self.tblcomment.dataSource = self
        let footervw = UIView.init(frame: .zero)
        self.tblcomment.tableFooterView = footervw
        
        self.setInputbar()
    }
    
    func managekeyboard() {
        self.view.keyboardTriggerOffset = self.inputvalues.frame.size.height
        self.view.addKeyboardNonpanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            var toolBarFrame = self.inputvalues.frame
            var tableViewFrame = self.tblcomment.frame
            if UIScreen.main.bounds.height >= 812 {
                tableViewFrame.size.height = toolBarFrame.origin.y - 95
                if #available(iOS 11.0, *) {
                    if keyboardFrameInView.origin.y == SCREENHEIGHT() {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height -  (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
                    }
                    else {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height
                    }
                }
                else {
                    toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height
                }
                self.inputvalues.frame = toolBarFrame
            }
            else {
                if keyboardFrameInView.origin.y == SCREENHEIGHT() {
                    tableViewFrame.size.height = toolBarFrame.origin.y - 80
                }
                else {
                    tableViewFrame.size.height = toolBarFrame.origin.y - 65
                }
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
                self.inputvalues.frame = toolBarFrame
            }
            
            self.tblcomment.frame = tableViewFrame
            self.tableViewScrollToBottomAnimated(animated: false)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tblcomment.addGestureRecognizer(tap)
        if self.arrComments_ChannelVideo.count > 0 {
            self.tableViewScrollToBottomAnimated(animated: false)
        }
    }
    
    func setInputbar() {
        self.inputvalues.placeholder = "Write a comment..."
        self.inputvalues.rightButtonImage =  #imageLiteral(resourceName: "send_btn")
        self.inputvalues.inputDelegate = self
    }
    
    func tableViewScrollToBottomAnimated(animated:Bool) {
        if(self.arrComments_ChannelVideo.count > 0) {
            self.tblcomment.scrollToRow(at: IndexPath(item:self.arrComments_ChannelVideo.count-1, section: 0), at: .bottom, animated: animated)
        }
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        self.inputvalues.inputResignFirstResponder()
    }
    
    // MARK: Button Action Method
    @IBAction func btnbackclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    //MARK: API
    func api_AddChannelComment(parameter: NSDictionary) {
        self.view.endEditing(true)
        //kData as NSString
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannelComment, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddChannelComment(parameter: parameter)
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
                        let objCommentData = CommentData.init(object: dicRespo)
                        self.arrComments_ChannelVideo.append(objCommentData)
                        
                        //Insert Comment Cell & Reload Table
                        self.tblcomment.beginUpdates()
                        self.tblcomment.insertRows(at: [IndexPath.init(row: self.arrComments_ChannelVideo.count - 1, section: 0)], with: .none)
                        self.tblcomment.endUpdates()
                        self.tableViewScrollToBottomAnimated(animated: false)
                        
                        //Called Notif.Obs. for show added Channel Video Comment counter in Privious VC
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_AddChannelVideoRefresh), object: nil, userInfo: nil) // ChannelListVC
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_MySingalChannelVideoList), object: nil, userInfo: nil) // ChannelProfilVC
                    }
                    else {
                        showMessage(statusmessage)
                    }
                }
            }
        })
    }
    
    func api_DeleteComment(parameter : NSDictionary)
    {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIRemoveChannelComment, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_DeleteComment(parameter: parameter)
                })
                return
            }
            else
            {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                }
            }
        })
    }
}

extension ChannelCommentVC:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noOfRow : Int = arrComments_ChannelVideo.count
        if (noOfRow == 0) {
            TableEmptyMessage(modulename: "Comment", tbl: tblcomment)
        }
        else {
            tableView.backgroundView = UIView.init()
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCommentCell") as! ChannelCommentCell
        
        let objComment = arrComments_ChannelVideo[indexPath.row]
        
        cell.imgProfile.sd_setImage(with:URL.init(string: objComment.imagePath!) , placeholderImage: ProfilePlaceholderImage)
        cell.lblUserName.text = objComment.fullName
        //Date---->
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: objComment.creationDatetime!) as Date
        cell.lblTime.text = timeAgoSinceDate(date: date, numericDates: false)
        // Comment---->
        cell.lblComment.text = objComment.commentVal
        cell.lblComment.numberOfLines = 0
        cell.lblComment.sizeToFit()
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        
        let objComment = self.arrComments_ChannelVideo[editActionsForRowAt.row]
        let strCommentAddedUserID : String = objComment.userId!
        if (strCommentAddedUserID.uppercased() != UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            return []
        }
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("Delete button tapped")
            
            let objComment = self.arrComments_ChannelVideo[editActionsForRowAt.row]
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIRemoveChannelComment,
                                          "request":["comment_id": objComment.id],
                                          "auth" : getAuthForService()]
            self.api_DeleteComment(parameter: parameter)
            
            //Remove Object in array list | 1st Remove obj after add object of it's index
            self.arrComments_ChannelVideo.remove(at:editActionsForRowAt.row)
            
            //Reload Table
            self.tblcomment.reloadData()
            
            //Called Notif.Obs. for show added Channel Video Comment counter in Privious VC
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_AddChannelVideoRefresh), object: nil, userInfo: nil) // ChannelListVC
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_MySingalChannelVideoList), object: nil, userInfo: nil) // ChannelProfilVC
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
}
extension ChannelCommentVC:InputbarDelegate
{
    func inputbarDidPressRightButton(inputbar:Inputbar)
    {
        let strComment : NSString = TRIM(string: inputbar.text).nsString
        if strComment.length == 0 {
            return
        }
        
        let parameter:NSDictionary = ["service":APIAddChannelComment,
                                      "request":["channel_video_id":strChannelVideoID,
                                                 "comment":strComment],
                                      "auth" : getAuthForService()]
        self.api_AddChannelComment(parameter: parameter)
    }
    
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    
    func inputbarDidPressLeftButton(inputbar:Inputbar) {
    }
    
    func inputbarDidBecomeFirstResponder(inputbar:Inputbar) {
    }
    
    func inputbarDidChangeHeight(newHeight:CGFloat) {
        self.view.keyboardTriggerOffset = newHeight
    }
}
