//
//  StarredMessagesVC.swift
//  WakeUppApp
//
//  Created by Admin on 26/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol StarredChatClickedDeleate:class {
    func btnStarredChatClicked(_ sender: UIButton)
}

class StarredMessagesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearchBar: UISearchBar!
    @IBOutlet var heightTxtSearchBar: NSLayoutConstraint!
    @IBOutlet weak var vwNoData: UIView!
    
    var arrStarredMessages = [Any]()

    var documentInteraction = UIDocumentInteractionController()

    var isDownloading : Bool = false {
        didSet{
            if isDownloading{
                showLoaderHUD(strMessage: "")
            }else{
                hideLoaderHUD()
            }
        }
    }
    
    var arrDownloadURLs = Array<URL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadStarredMessages()
        
        txtSearchBar.delegate = self
        heightTxtSearchBar.constant = 0
    }
    
    func loadStarredMessages(){
        
        let arrStarredChatMessages = CoreDBManager.sharedDatabase.getStarredChatMessages()
        let arrStarredGroupMessages = CoreDBManager.sharedDatabase.getStarredGroupMessages()
        
        arrStarredMessages.removeAll()
        arrStarredMessages.append(contentsOf: (arrStarredChatMessages as [Any]))
        arrStarredMessages.append(contentsOf: (arrStarredGroupMessages as [Any]))
        
        if (txtSearchBar.text!.count > 0){
            var arrSearchedMessages = [Any]()
            let searchText = txtSearchBar.text!
            for msg in arrStarredMessages{
                if msg is StructChat{
                    let chatModel = msg as! StructChat
                    if chatModel.kmessagetype == "0"{
                        if chatModel.kchatmessage.base64Decoded!.contains(searchText){
                            arrSearchedMessages.append(chatModel)
                        }
                    }
                }else{
                    let groupChatModel = msg as! StructGroupChat
                    if groupChatModel.messagetype == "0"{
                        if groupChatModel.textmessage.base64Decoded!.contains(searchText){
                            arrSearchedMessages.append(groupChatModel)
                        }
                    }
                }
            }
            arrStarredMessages = arrSearchedMessages
        }
        
        arrStarredMessages = arrStarredMessages.sorted(by: { (obj1, obj2) -> Bool in
            var strDt1 = ""
            var strDt2 = ""
            
            if obj1 is StructChat{
                let chatObj1 = obj1 as! StructChat
                strDt1 = chatObj1.kcreateddate
            }else{
                let groupChatObj1 = obj1 as! StructGroupChat
                strDt1 = groupChatObj1.createddate
            }
            
            if obj2 is StructChat{
                let chatObj2 = obj2 as! StructChat
                strDt2 = chatObj2.kcreateddate
            }else{
                let groupChatObj2 = obj2 as! StructGroupChat
                strDt2 = groupChatObj2.createddate
            }
            
            let dt1 = getChatDateFromString(dategiven: strDt1)
            let dt2 = getChatDateFromString(dategiven: strDt2)
            
            return dt1.compare(dt2 as Date) == .orderedDescending
        })
        
        if arrStarredMessages.count == 0{
            tableView.isHidden = true
            vwNoData.isHidden = false
        }else{
            tableView.isHidden = false
            vwNoData.isHidden = true
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchClicked(_ sender: Any) {
        if heightTxtSearchBar.constant == 0{
            heightTxtSearchBar.constant = 56
            txtSearchBar.becomeFirstResponder()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }else{
            hideSearchBar()
        }
    }
    
}

extension StarredMessagesVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = arrStarredMessages[indexPath.row]
        
        var strName = ""
        var strProfilePath = ""
        var date = ""
        var time = ""
        var message = ""
        var imgDocType = UIImage.init()
        var attachmentPath = ""
        
        var arrDateTime = [String]()
        
        var isAttachment = false
        var isLocation = false
        var isDocument = false
        var isContact = false
        var isStoryReply = false
        var isTextMessage = false
        
        var isPersonalChat = false
        
        if model is StructChat{
            
            isPersonalChat = true
            
            let chatModel = model as! StructChat
            
            let userModel = CoreDBManager.sharedDatabase.getFriendById(userID: chatModel.ksenderid)!
            strName = userModel.kusername
            
            if userModel.kuserprofile.count != 0{
                strProfilePath = "\(Get_Profile_Pic_URL)\(userModel.kuserprofile)"
            }
            
            if chatModel.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                strProfilePath = UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
                strName = UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
            }
            
            arrDateTime = chatModel.kcreateddate.components(separatedBy: "T")
            
            let messageType = Int(chatModel.kmessagetype)!
            switch messageType{
            case 0:
                isTextMessage = true
                message = chatModel.kchatmessage.base64Decoded!
                break;
            case 1:
                attachmentPath = chatModel.kmediaurl
                if isPathForContact(path: attachmentPath){
                    isContact = true
                    message = chatModel.kchatmessage.base64Decoded!
                }else if isPathForImage(path: attachmentPath) || isPathForVideo(path: attachmentPath){
                    isAttachment = true
                }else{
                    isDocument = true
                    imgDocType = getFileIcon(for: attachmentPath)
                    message = getFileType(for: attachmentPath)
                }
                break;
            case 2:
                isLocation = true
                break;
            case 3:
                isStoryReply = true
                let arrDetails = chatModel.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                attachmentPath = arrDetails[1]
                message = arrDetails[4]
                break;
            default:
                break
            }
        }else{
            let groupChatModel = model as! StructGroupChat
            
            let groupModel = CoreDBManager.sharedDatabase.getGroupById(groupId: groupChatModel.groupid)!
            strName = groupChatModel.sendername + " in " + groupModel.name
            strProfilePath = groupModel.icon
            
            arrDateTime = groupChatModel.createddate.components(separatedBy: "T")
            
            let messageType = Int(groupChatModel.messagetype)!
            switch messageType{
            case 0:
                isTextMessage = true
                message = groupChatModel.textmessage.base64Decoded! //chatModel.kchatmessage.base64Decoded!
                break;
            case 1:
                attachmentPath = groupChatModel.mediaurl
                if isPathForContact(path: attachmentPath){
                    isContact = true
                    message = groupChatModel.textmessage.base64Decoded!
                }else if isPathForImage(path: attachmentPath) || isPathForVideo(path: attachmentPath){
                    isAttachment = true
                }else{
                    isDocument = true
                    imgDocType = getFileIcon(for: attachmentPath)
                    message = getFileType(for: attachmentPath)
                }
                break;
            case 2:
                isLocation = true
                break;
            /*case 3:
                //NOT POSSIBLE IN GROUP CHAT
                break;*/
            default:
                break;
            }
        }
        
        date = arrDateTime.first!
        
        let arrDateComponents = date.components(separatedBy: "-")
        date = arrDateComponents[2] + "-" + arrDateComponents[1] + "-" + arrDateComponents[0].charactersArray.suffix(2)
        
        time = arrDateTime.last!.components(separatedBy: ".").first!
        
        if isAttachment || isLocation{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StarredChatAttachmentCell", for: indexPath) as! StarredChatAttachmentCell
            
            cell.imgAttachment.image = nil
            
            setProfileImageInCell(imgProfile: cell.imgProfile, profilePath: strProfilePath, isPersonalChat: isPersonalChat)
            cell.lblName.text = strName
            cell.lblDate.text = date
            cell.lblTime.text = time
            
            if isAttachment{
                cell.imgAttachment.image = nil
                if isPathForImage(path: attachmentPath){
                    cell.imgAttachment.backgroundColor = .clear
                    cell.imgPlay.isHidden = true
                    cell.imgAttachment.sd_setImage(with: attachmentPath.toUrl, completed: nil)
                }else{
                    cell.imgAttachment.backgroundColor = .black
                    cell.imgPlay.isHidden = false
                }
            }else{
                cell.imgPlay.isHidden = true

                cell.imgAttachment.image = #imageLiteral(resourceName: "img_map")
            }
            
            cell.starredChatClickedDelegate = self
            cell.btnStarredChat.tag = indexPath.row
            
            return cell
        }
        
        if isContact{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StarredChatContactCell", for: indexPath) as! StarredChatContactCell
            
            setProfileImageInCell(imgProfile: cell.imgProfile, profilePath: strProfilePath, isPersonalChat: isPersonalChat)
            cell.lblName.text = strName
            cell.lblDate.text = date
            cell.lblTime.text = time
            
            cell.lblContact.text = message
            
            cell.starredChatClickedDelegate = self
            cell.btnStarredChat.tag = indexPath.row
            
            return cell
        }
        
        if isDocument{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StarredChatDocumentCell", for: indexPath) as! StarredChatDocumentCell
            
            setProfileImageInCell(imgProfile: cell.imgProfile, profilePath: strProfilePath, isPersonalChat: isPersonalChat)
            cell.lblName.text = strName
            cell.lblDate.text = date
            cell.lblTime.text = time
            
            cell.lblDocumentType.text = message
            cell.imgDocumentType.image = imgDocType
            
            cell.starredChatClickedDelegate = self
            cell.btnStarredChat.tag = indexPath.row
            
            return cell
        }
        
        if isStoryReply{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StarredChatStoryReplyCell", for: indexPath) as! StarredChatStoryReplyCell

            setProfileImageInCell(imgProfile: cell.imgProfile, profilePath: strProfilePath, isPersonalChat: isPersonalChat)
            cell.lblName.text = strName
            cell.lblDate.text = date
            cell.lblTime.text = time
            
            cell.lblMessage.text = message
            
            if isPathForImage(path: attachmentPath){
                cell.imgStory.sd_setImage(with: attachmentPath.toUrl, completed: nil)
            }else{
                DispatchQueue.global().async {
                    let asset = AVAsset(url: attachmentPath.toUrl!)
                    let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                    assetImgGenerate.appliesPreferredTrackTransform = true
                    let time = CMTimeMake(1, 2)
                    let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                    if img != nil {
                        let frameImg  = UIImage(cgImage: img!)
                        DispatchQueue.main.async(execute: {
                            cell.imgStory.image = frameImg
                        })
                    }
                }
            }
            
            cell.starredChatClickedDelegate = self
            cell.btnStarredChat.tag = indexPath.row
            
            return cell
        }
        
        if isTextMessage{
            let cell = tableView.dequeueReusableCell(withIdentifier: "StarredChatTextCell", for: indexPath) as! StarredChatTextCell
            
            setProfileImageInCell(imgProfile: cell.imgProfile, profilePath: strProfilePath, isPersonalChat: isPersonalChat)
            cell.lblName.text = strName
            cell.lblDate.text = date
            cell.lblTime.text = time
            
            cell.lblMessage.text = message
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStarredMessages.count
    }
    
    func setProfileImageInCell(imgProfile:UIImageView, profilePath:String, isPersonalChat:Bool){
        imgProfile.contentMode = .scaleAspectFill
        if profilePath.count == 0{
            if isPersonalChat{
                imgProfile.image = #imageLiteral(resourceName: "user_notification")
            }else{
                imgProfile.image = #imageLiteral(resourceName: "addgroup_pic")
            }
        }else{
            imgProfile.sd_setImage(with: profilePath.toUrl, completed: { (image, error, cacheType, url) in
                if error != nil{
                    self.setProfileImageInCell(imgProfile: imgProfile, profilePath: "", isPersonalChat: isPersonalChat)
                }
            })
        }
    }
}

extension StarredMessagesVC : StarredChatClickedDeleate{
    func btnStarredChatClicked(_ sender: UIButton) {
        
        var attachmentPath = ""
        
        var isAttachment = false
        var isLocation = false
        var isDocument = false
        var isContact = false
        var isStoryReply = false
        
        let model = arrStarredMessages[sender.tag]
        if model is StructChat{
            let chatModel = model as! StructChat
            let messageType = Int(chatModel.kmessagetype)!
            switch messageType{
            case 1:
                attachmentPath = chatModel.kmediaurl
                if isPathForContact(path: attachmentPath){
                    isContact = true
                }else if isPathForImage(path: attachmentPath) || isPathForVideo(path: attachmentPath){
                    isAttachment = true
                }else{
                    isDocument = true
                }
                break;
            case 2:
                isLocation = true
                attachmentPath = chatModel.kchatmessage
                break;
            case 3:
                isStoryReply = true
                let arrDetails = chatModel.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                attachmentPath = arrDetails[1]
                break;
            default:
                break
            }
        }else{
            let groupChatModel = model as! StructGroupChat
            let messageType = Int(groupChatModel.messagetype)!
            switch messageType{
            case 1:
                attachmentPath = groupChatModel.mediaurl
                if isPathForContact(path: attachmentPath){
                    isContact = true
                }else if isPathForImage(path: attachmentPath) || isPathForVideo(path: attachmentPath){
                    isAttachment = true
                }else{
                    isDocument = true
                }
                break;
            case 2:
                isLocation = true
                attachmentPath = groupChatModel.textmessage
                break;
            default:
                break;
            }
        }
        
        print(attachmentPath)
        
        let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0))
        openAttachment(fromCell:cell!, attachmentPath: attachmentPath, isAttachment: isAttachment, isLocation: isLocation, isDocument: isDocument, isContact: isContact, isStoryReply: isStoryReply)
    }
}

extension StarredMessagesVC{
    
    func getChatDateFromString(dategiven:String) -> NSDate{
        var strDate = dategiven.replacingOccurrences(of: " ", with: "T")
        if strDate.components(separatedBy: ".").count < 2{
            strDate = "\(strDate).000Z"
        }
        
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        /*if dategiven.contains("'") == false{
         dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ"
         }*/
        let inputTimeZone = NSTimeZone(abbreviation: "UTC")
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = inputTimeZone as TimeZone!
        inputDateFormatter.dateFormat = dateFormat
        let date = inputDateFormatter.date(from: strDate)
        let outputTimeZone = NSTimeZone.local
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        let outputString = outputDateFormatter.string(from: date!)
        return outputDateFormatter.date(from: outputString)! as NSDate
    }
    
}

extension StarredMessagesVC : UIDocumentInteractionControllerDelegate{
    
    func openAttachment(fromCell:UITableViewCell, attachmentPath:String, isAttachment:Bool, isLocation:Bool, isDocument:Bool, isContact:Bool, isStoryReply:Bool){
        
        if isPathForImage(path: attachmentPath){
            let configuration = ImageViewerConfiguration { config in
                config.imageView = fromCell.viewWithTag(15) as? UIImageView
            }
            let imageViewerController = ImageViewerController(configuration: configuration)
            present(imageViewerController, animated: true)
        }
        else if isLocation{
            //print("//OPEN LOCATION")
            
            let arrLocation = attachmentPath.base64Decoded!.components(separatedBy: ",")
            let latitude = arrLocation.first
            let longitude = arrLocation.last
            if latitude != nil && longitude != nil {
                //Abrimos Google Maps...
                if let aString = URL(string: "comgooglemaps://") {
                    if UIApplication.shared.canOpenURL(aString) {
                        if let aValue = URL(string: String(format: "comgooglemaps://?q=%.6f,%.6f&center=%.6f,%.6f&zoom=15&views=traffic", Double(latitude ?? "0")!, Double(longitude ?? "0")!, Double(latitude ?? "0")!, Double(longitude ?? "0")!)) {
                            //UIApplication.shared.openURL(aValue)
                            UIApplication.shared.open(aValue, options: [:], completionHandler: { (success) in
                                //print("Open GMaps App : \(success ? "SUCCESS" : "FAILURE")")
                            })
                        }
                    } else {
                        if let aValue = URL(string: String(format: "https://maps.google.com/maps?&z=15&q=%.6f+%.6f&ll=%.6f+%.6f", Double(latitude ?? "0")!, Double(longitude ?? "0")!, Double(latitude ?? "0")!, Double(longitude ?? "0")!)) {
                            //UIApplication.shared.openURL(aValue)
                            UIApplication.shared.open(aValue, options: [:], completionHandler: { (success) in
                                //print("Open GMaps App : \(success ? "SUCCESS" : "FAILURE")")
                            })
                        }
                    }
                }
            }
            
        }
        else {
            if isPathForAudio(path: attachmentPath){
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
                vc.modalPresentationStyle = .overCurrentContext
                vc.audioURL = attachmentPath
                present(vc, animated: true, completion: nil)
            }
            else{
                downloadAndOpenAttachment(url: URL.init(string: attachmentPath)!)
            }
        }
    }
    
    func downloadAndOpenAttachment(url:URL){
        if isFileLocallySaved(fileUrl: url){
            
            let localURL = getLocallySavedFileURL(with: url)!
            
            if isPathForVideo(path: localURL.path){
                
                let player = AVPlayer(url: localURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                
            }
            else{
                documentInteraction = UIDocumentInteractionController.init(url: localURL)
                documentInteraction.delegate = self
                let success = documentInteraction.presentPreview(animated: true)
                if success == false{
                    //print("//OPEN AS MENU")
                    documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
                
            }
            
        }else{
            
            if arrDownloadURLs.contains(url) == false{
                arrDownloadURLs.append(url)
            }
            
            performDownload()
            
        }
    }
    
    func performDownload(){
        guard isDownloading == false else{
            return
        }
        if arrDownloadURLs.count > 0{
            isDownloading = true
            
            Downloader.download(url: arrDownloadURLs[0], completion: { (success, url) in
                if success{
                    
                    //OTHERWISE THE DOCUMENT / VIDEO VIEWER WILL OPEN ANYTIME WHEN THE DOWNLOAD FINISHES
                    //WE SHOULD INDICAT IF THE FILE IS READY TO BE DISPLAYED OR NOT
                    //SO IF DOWNLOADED THEN WILL OPEN DIRECTLY
                    //OTHERWISE DOWNLOAD ONLY (OPEN NEXT TIME WHEN USER TAPS FILE)
                    //self.downloadAndOpenAttachment(url: url)
                    
                    self.arrDownloadURLs.remove(at: 0)
                }else{
                    showStatusBarMessage("Download failed. Try again.")
                }
                self.isDownloading = false
                self.performDownload()
            })
        }
    }
    
    internal func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return mostTopViewController!
    }
    
    func hideSearchBar(){
        txtSearchBar.resignFirstResponder()
        txtSearchBar.text = ""
        heightTxtSearchBar.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        loadStarredMessages()
    }
    
}

extension StarredMessagesVC: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        loadStarredMessages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}
