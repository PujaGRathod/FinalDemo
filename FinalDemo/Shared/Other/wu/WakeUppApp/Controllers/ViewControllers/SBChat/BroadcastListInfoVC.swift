//
//  BroadcastListInfoVC.swift
//  WakeUppApp
//
//  Created by Admin on 29/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SDWebImage

class BroadcastListInfoVC: UIViewController {
    //MARK:- Outlet
    @IBOutlet weak var lblBroadcastListName: UILabel!
    @IBOutlet weak var lblCreatedByAndOn: UILabel!
    @IBOutlet weak var lblNoOfParticipants: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblNoOfMediaContent: UILabel!
    
    //MARK:- Variable
    var selectedBroadcastListDetails:StructBroadcastList!
    
    var arrMemberNames = [String]()
    var arrMemberPhotos = [String]()
    
    //Use for show memeber name as stored in local contact.
    var arrMember_IDs : [String] = []
    var arrMember_CountryCode : [String] = []
    var arrMember_PhoneNo : [String] = []
    var photoBrowser:ChatAttachmentBrowser! //PV
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        self.set_UserID_and_PhoneNo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setData()
    }
    
    //MARK:- Manage Broadcast list included user info stoed in particuler array stoed info. 
    func set_UserID_and_PhoneNo() -> Void {
        let arrMember : [String] = selectedBroadcastListDetails.members.components(separatedBy: ",")
        for objUser : String in arrMember {
            let arrUserInfo = objUser.components(separatedBy: "_")
            
            //ID
            let strUserID : String = arrUserInfo.first ?? "0"
            arrMember_IDs.append(strUserID)
            
            //CountryCode
            let strUserCountryCode : String = arrUserInfo[1]
            arrMember_CountryCode.append(strUserCountryCode)
            
            //PhonrNo
            let strUserPhoneno : String = arrUserInfo.last ?? "0"
            arrMember_PhoneNo.append(strUserPhoneno)
        }
    }
    
    func setData() {
        selectedBroadcastListDetails = CoreDBManager.sharedDatabase.getBroadcastListById(Id: selectedBroadcastListDetails.broadcastListID)
        lblBroadcastListName.text = selectedBroadcastListDetails.name
        lblCreatedByAndOn.text = "Created by You"
        
        //No. Of Media Content
        self.lblNoOfMediaContent.text = "\(self.getData_NoOfMediaContent().count)"
        //self.lblNoOfMediaContent.text = ""
        
        arrMemberNames = selectedBroadcastListDetails.memberNames.components(separatedBy: ",")
        arrMemberPhotos = selectedBroadcastListDetails.memberPhotos.components(separatedBy: ",")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        lblNoOfParticipants.text = "\(selectedBroadcastListDetails.members.components(separatedBy: ",").count) of \(kMaxMembersInBroadcast)"
    }
    
    func getData_NoOfMediaContent() -> [URL] {
        let URL_dirCurrentGroupChat : URL = getURL_BroadcastChat_Directory(BroadcastID: selectedBroadcastListDetails.broadcastListID)
        let totalContent = getAllContent(inDirectoryURL: URL_dirCurrentGroupChat)
        
        var arrMediaURLs : [URL] = []
        for localURL in totalContent {
            if isPathForImage(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
            else if isPathForVideo(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
        }
        return arrMediaURLs
    }
    
    //MARK:- Button action methods
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            //print("DELETE BROADCAST LIST WITH ID : \(self.selectedBroadcastListDetails.broadcastListID)")
            if CoreDBManager.sharedDatabase.deleteBroadcastList(broadcastListID: self.selectedBroadcastListDetails.broadcastListID){
                let viewControllers: [UIViewController] = APP_DELEGATE.appNavigation!.viewControllers as [UIViewController]
                APP_DELEGATE.appNavigation!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }else{
                //print("COULD NOT DELETE BROADCAST LIST")
            }
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        alert.addAction(actionDelete)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnEditGroupClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Broadcast List Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Write name of this broadcast list"
            textField.text = self.selectedBroadcastListDetails.name
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { action -> Void in
            let txtName = alert.textFields![0] as UITextField
            if let newName = txtName.text{
                //print("UPDATE BROADCAST LIST NAME OF ID : \(self.selectedBroadcastListDetails.broadcastListID) WITH \(newName)")
                self.selectedBroadcastListDetails.name = newName
                CoreDBManager.sharedDatabase.updateBroadcastListDetails(updatedBroadcastlist: self.selectedBroadcastListDetails)
                self.setData()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.view.tintColor = themeWakeUppColor
        present(alert, animated: true, completion: nil)
        
        //TO REMOVE BORDERS OF TEXTFIELD IN ALERT
        /*for textfield in alert.textFields! {
         let container = textfield.superview
         let effectView = container?.superview?.subviews[0]
         if let effectsView = effectView{
         if effectsView is UIVisualEffectView{
         effectsView.removeFromSuperview()
         }
         }
         }*/
    }
   
    @IBAction func btnNoOfMediaContentAction(_ sender: Any) {
        let URL_dirCurrentGroupChat : URL = getURL_BroadcastChat_Directory(BroadcastID: selectedBroadcastListDetails.broadcastListID)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: URL_dirCurrentGroupChat)
        var arrMediaURLs : [String] = []
        var arrLinkURLs : [String] = []
        var arrDocsURLs : [String] = []
        for localURL in arrMediaURLInLocalDir {
            //Media
            if isPathForImage(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            else if isPathForVideo(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            
            //Docs
            else if isPathForAudio(path: localURL.absoluteString) { arrDocsURLs.append(localURL.absoluteString) }
            else if isPathForContact(path: localURL.absoluteString) { arrDocsURLs.append(localURL.absoluteString) }
            else { arrDocsURLs.append(localURL.absoluteString) }
        }
        
        //------------->
        //Docs -> Get and set Doc real name
        var arrDocument : [objDocumentInfo] = []
        for objURL in arrDocsURLs {
            let docsURL : URL = objURL.url!
            
            let objData = CoreDBManager.sharedDatabase.getDocumentForBroadcastList(broadcastListId: selectedBroadcastListDetails.broadcastListID, filename: docsURL.lastPathComponent)
            var strDocName : String = objData.textmessage.base64Decoded ?? ""
            if (strDocName.count == 0) { strDocName = docsURL.lastPathComponent }
            //print("strDocName: \(strDocName)")
            
            let objDocument = objDocumentInfo.init(strURL: objURL,
                                                   name: strDocName,
                                                   size: fileSizedetail(url: docsURL),
                                                   createDate: getfileCreatedDate(url: docsURL),
                                                   type: getFileType(for: objURL))
            arrDocument.append(objDocument)
        }
        //<-------------
        
        let action = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        //Media --------------->
        //if (arrMediaURLs.count != 0) {
            let action_Media = UIAlertAction.init(title: "Media", style: .default, handler: { (action) in
                self.photoBrowser = ChatAttachmentBrowser.init(broadcastListID: self.selectedBroadcastListDetails.broadcastListID, currentLocalDir: URL_dirCurrentGroupChat)
                self.photoBrowser.openBrowser()
            })
            action.addAction(action_Media)
        //}
        
        //Docs --------------->
        //if (arrDocument.count != 0) {
            let action_Docs = UIAlertAction.init(title: "Docs", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAttachMediaVC") as! ChatAttachMediaVC
                objVC.objEnumAttachMedia = .Docs
                
                let mediaContent = objAttachMedia.init(arrMedia: [],
                                                       arrLinks: [],
                                                       arrDocument: arrDocument)
                objVC.objMediaContent = mediaContent
                
                objVC.URL_CurrentDir = URL_dirCurrentGroupChat
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            })
            action.addAction(action_Docs)
        //}
        
        //Link --------------->
        let arrMsgs = CoreDBManager.sharedDatabase.getMessagesForBroadcastListID(broadcastListID: selectedBroadcastListDetails.broadcastListID)
        for obj in arrMsgs {
            if obj.messagetype == "4" { arrLinkURLs.append(obj.mediaurl) }
        }
        
        //if (arrLinkURLs.count != 0) {
            let action_Links = UIAlertAction.init(title: "Links", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAttachMediaVC") as! ChatAttachMediaVC
                objVC.objEnumAttachMedia = .Links
                
                let objLinksInfo = LinksInfo.init(arrLinks: arrLinkURLs)
                objVC.objLinksInfo = objLinksInfo
                
                objVC.URL_CurrentDir = URL_dirCurrentGroupChat
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            })
            action.addAction(action_Links)
        //}
        
        //if action.actions.count != 0 {
            let action_Cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            action.addAction(action_Cancel)
            
            self.present(action, animated: true, completion: nil)
        //}
    }
    
    @IBAction func btnAddParticipantClicked(_ sender: Any) {
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
        //vc.forAddMembersInBroadcastList = true
        vc.objEnumSelectMember = .enumSelectMember_AddMembersInBroadcast
        
        //vc.preSelectedUserIDs = selectedBroadcastListDetails.members.components(separatedBy: ",")
        vc.preSelectedUserIDs = self.arrMember_IDs
        
        vc.selectedBroadcastListForAddMembers = selectedBroadcastListDetails
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BroadcastListInfoVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let imgView = cell.viewWithTag(11) as! UIImageView
        imgView.sd_setImage(with: URL.init(string: arrMemberPhotos[indexPath.row]), placeholderImage: ProfilePlaceholderImage, options: []) { (image, error, cachetype, url) in
        }
        
        let lblName = cell.viewWithTag(12) as! UILabel
        let lblSubName = cell.viewWithTag(13) as! UILabel 
        
        //lblName.text = arrMemberNames[indexPath.row]
        var strUser_FullName : String = ""
        strUser_FullName = arrMemberNames[indexPath.row]
        let indexOfUser = arrMemberNames.index(of: strUser_FullName)
        
        let strCountryCode = arrMember_CountryCode[indexOfUser!]
        let strPhoneNo = arrMember_PhoneNo[indexOfUser!]
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: strCountryCode, phoneNo: strPhoneNo)
        
        if objContactInfo.Name?.count == 0 {
            //lblName.text = strUser_FullName
            lblName.text = "+\(strCountryCode) \(strPhoneNo)"
            lblSubName.text = "~\(strUser_FullName)"
        }
        else {
            lblName.text = objContactInfo.Name ?? "*** No name ***"
            lblSubName.text = "~\(strUser_FullName)"
        }
        lblSubName.text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedBroadcastListDetails.members.components(separatedBy: ",").count
    }
}

