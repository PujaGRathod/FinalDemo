//
//  CommentsVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 23/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CommentsVC: UIViewController {
    
    // MARK:- Outlet
    @IBOutlet var btnback: UIButton!
    @IBOutlet var tblcomment: UITableView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet var inputvalues: Inputbar!
    
    // MARK:- Variable
    var strPostID : String = "0" // For use get particuler video's add comment, This values get in privious VC
    //var arrPostComments = [CommentData]() // For use get all video comment in objSelectedChannelVideo object.
    var arrPostComments = [LikeData]() // For use get all video comment in objSelectedChannelVideo object.
    var strPlaceholder : String = "Loading..."
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
        
        //Get Comment Data
        self.api_GetPostComment(strPostID: strPostID)
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.managekeyboard()
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        self.view.removeKeyboardControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- Custom Function
    func layoutUI() {
        IQKeyboardManager.shared.enable = false
        self.tblcomment.delegate = self
        self.tblcomment.dataSource = self
        let footervw = UIView.init(frame: .zero)
        self.tblcomment.tableFooterView = footervw
        
        self.setInputbar()
    }
    
    // MARK:- Button Action Method
    @IBAction func btnbackclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
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
        if self.arrPostComments.count > 0 {
            self.tableViewScrollToBottomAnimated(animated: false)
        }
    }
    
    func setInputbar() {
        self.inputvalues.placeholder = "Write a comment..."
        self.inputvalues.rightButtonImage =  #imageLiteral(resourceName: "send_btn")
        self.inputvalues.inputDelegate = self
    }
    
    func tableViewScrollToBottomAnimated(animated:Bool) {
        if(self.arrPostComments.count > 0) {
            self.tblcomment.scrollToRow(at: IndexPath(item:self.arrPostComments.count-1, section: 0), at: .bottom, animated: animated)
        }
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        self.inputvalues.inputResignFirstResponder()
    }
    
    //MARK:- API
    func api_GetPostComment(strPostID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetAllPostLikeComment,
                                      "request":["post_id":strPostID,
                                                 "action":"comment"],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetAllPostLikeComment, parameters: parameter, keyname: kData as NSString, message: "Get Commnet Data", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            //Hide Loader
            hideMessage()
            hideLoaderHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetPostComment(strPostID: strPostID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    self.arrPostComments = responseArray as! [LikeData]
                    self.strPlaceholder = "No Comment Available"
                    self.tblcomment.reloadData()
                }
            }
        })
    }
    
    func api_AddPostComment(parameter: NSDictionary) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddPostComment, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddPostComment(parameter: parameter)
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
                        let objCommentData = LikeData.init(object: dicRespo)
                        self.arrPostComments.append(objCommentData)
                        
                        //Insert Comment Cell & Reload Table
                        self.tblcomment.beginUpdates()
                        self.tblcomment.insertRows(at: [IndexPath.init(row: self.arrPostComments.count - 1, section: 0)], with: .none)
                        self.tblcomment.endUpdates()
                        self.tableViewScrollToBottomAnimated(animated: false)
                        
                        //Called Notif.Obs. for show added Post Comment counter in Privious Screen (FeedVC).
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_AddPostCommentRefresh), object: nil, userInfo: nil) // FeedVC
                    }
                    else {
                        showMessage(statusmessage)
                    }
                }
            }
        })
    }
    
    func api_DeletePostComment(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIRemovePostComment, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_DeletePostComment(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                    
                    //Called Notif.Obs. for show remove Post Comment counter in Privious Screen (FeedVC).
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_RemovePostCommentRefresh), object: nil, userInfo: nil) // FeedVC
                }
            }
        })
    }
}

extension CommentsVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noOfRow = arrPostComments.count
        
        //  tblcomment.isHidden = true
        lblPlaceholder.isHidden = true
        if (noOfRow == 0)
        {
            // lblPlaceholder.text = strPlaceholder.localizedUppercase
            //  lblPlaceholder.isHidden = false
            TableEmptyMessage(modulename: "Comment", tbl: tblcomment)
        }
        else {
            tableView.backgroundView = UIView.init()
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
        let objComment : LikeData = arrPostComments[indexPath.row] as LikeData
        let strPhotoURL : String = objComment.imagePath!
        let strFullName : String = objComment.fullName!
        //Date
        var strDate : String = objComment.creationDatetime!
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: objComment.creationDatetime!) as Date
        strDate = timeAgoSinceDate(date: date, numericDates: false)
        //Comment
        let strComment : String = objComment.commentVal!
        
        //Fill Values
        cell.imgrofile.sd_setImage(with:URL(string: strPhotoURL), placeholderImage: ProfilePlaceholderImage)
        
        cell.lbluname.text = strFullName
        cell.lbltime.text = strDate
        
        cell.lblcomment.text = strComment
        cell.lblcomment.numberOfLines = 0
        cell.lblcomment.sizeToFit()
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //--->
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let objComment = self.arrPostComments[editActionsForRowAt.row]
        let strCommentAddedUserID : String = objComment.userId!
        if (strCommentAddedUserID.uppercased() != UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            return []
        }
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("Delete button tapped")
            
            //let objComment = self.arrPostComments[editActionsForRowAt.row]
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIRemovePostComment, 
                "request":["comment_id": objComment.id],
                "auth" : getAuthForService()]
            self.api_DeletePostComment(parameter: parameter)
            
            //Remove Object in array list | 1st Remove obj after add object of it's index
            self.arrPostComments.remove(at:editActionsForRowAt.row)
            self.tblcomment.reloadData() //Reload Table
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
}

extension CommentsVC:InputbarDelegate {
    func inputbarDidPressRightButton(inputbar:Inputbar) {
        let strComment : NSString = TRIM(string: inputbar.text).nsString
        if strComment.length == 0 { return }
        
        let parameter:NSDictionary = ["service":APIAddPostComment,
                                      "request":["post_id":strPostID,
                                                 "comment":strComment],
                                      "auth" : getAuthForService()]
        self.api_AddPostComment(parameter: parameter)
    }
    
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    
    func inputbarDidPressLeftButton(inputbar:Inputbar) {
        //--->
    }
    
    func inputbarDidBecomeFirstResponder(inputbar:Inputbar) {
        //--->
    }
    
    func inputbarDidChangeHeight(newHeight:CGFloat) {
        self.view.keyboardTriggerOffset = newHeight
    }
}
