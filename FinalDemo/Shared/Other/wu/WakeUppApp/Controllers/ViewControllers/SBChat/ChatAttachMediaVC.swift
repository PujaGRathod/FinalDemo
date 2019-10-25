//
//  ChatAttachMediaVC.swift
//  WakeUppApp
//
//  Created by Admin on 16/08/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

enum enumAttachMedia : Int {
    case None = 0
    case Media
    case Links
    case Docs
}

struct objDocumentInfo {
    var strURL : String
    var name:String
    var size: String
    var createDate:String
    var type:String
}

struct objAttachMedia {
    var arrMedia : [String]
    var arrLinks : [String]
    var arrDocument : [objDocumentInfo]
}

struct MediaInfo {
    var arrMedia : [String]
}
struct LinksInfo {
    var arrLinks : [String]
}
/*struct DocsInfo {
    var arrDocs : [String]
}*/

class ChatAttachMediaVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblChatAttachMedia: UITableView!
    @IBOutlet weak var viewEmptyPlaceholder: UIView!
    @IBOutlet weak var lblEmptyMess: UILabel!
    
    // MARK: - Variable
    var objEnumAttachMedia : enumAttachMedia = .None //For manage what Data Show by getting value in Privious VC
    var URL_CurrentDir : URL? //Manage for play audio
    
    var arrDataList : [String] = []
    var objMediaInfo : MediaInfo = MediaInfo.init(arrMedia: [])
    var objLinksInfo : LinksInfo = LinksInfo.init(arrLinks: [])
    //var objDocsInfo : DocsInfo = DocsInfo.init(arrDocs: [])
    
    var objMediaContent : objAttachMedia = objAttachMedia.init(arrMedia: [], arrLinks: [], arrDocument: [])
    
    var documentInteraction = UIDocumentInteractionController()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch objEnumAttachMedia {
        case .Media:
            arrDataList = objMediaInfo.arrMedia
            self.lblTitle.text = "Media (\(arrDataList.count))"
            self.lblEmptyMess.text = "No Media content"
            break
            
        case .Links:
            arrDataList = objLinksInfo.arrLinks
            //self.lblTitle.text = "Links (\(arrDataList.count))"
            self.lblTitle.text = "Links (\(objMediaContent.arrLinks.count))"
            self.lblEmptyMess.text = "No Links content"
            break
        
        case .Docs:
            //arrDataList = objDocsInfo.arrDocs
            //arrDataList = objMediaContent.arrDocument.
            self.lblTitle.text = "Docs (\(objMediaContent.arrDocument.count))"
            self.lblEmptyMess.text = "No Docs content"
            break
            
        default:
            self.lblTitle.text = "Media, Links, and Docs"
            self.lblEmptyMess.text = ""
            arrDataList = []
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: -
    /*func getfileCreatedDate(url: URL?) -> String {
        
        guard let filePath = url?.path else {
            return ""
        }
        
        do {
            //let aFileAttributes = try FileManager.default.attributesOfItem(atPath: theFile) as [FileAttributeKey:Any]
            //theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
            
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let date = attribute[FileAttributeKey.creationDate] {
                //print("date: \(date)")
                
                //return date as! String
                var strDate : String = "\(date)"
                let date = covertTimeToLocalZone(time: strDate)
                //strDate = timeAgoSinceDate(date: date as Date, numericDates: true)
                strDate = DateFormater.generateDateForGivenDateToServerTimeZone(givenDate: date)
                return strDate.count == 0 ? "" : strDate
            }
            
        } catch let theError as Error {
            //print("file not found \(theError)")
            return ""
        }
        return ""
    }*/
    
    // MARK: - Button action method
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    // MARK: - Tableview delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noOfRow = 0
        
        switch objEnumAttachMedia {
        case .Media:
            noOfRow = objMediaContent.arrMedia.count
            break
        
        case .Docs:
            noOfRow = objMediaContent.arrDocument.count
            break
        
        case .Links:
            noOfRow = objMediaContent.arrLinks.count
            break
        case .None:
            break
        }
            
        self.tblChatAttachMedia.isHidden = true
        self.viewEmptyPlaceholder.isHidden = true
        if (noOfRow == 0) { self.viewEmptyPlaceholder.isHidden = false }
        else { self.tblChatAttachMedia.isHidden = false }
        
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch objEnumAttachMedia {
        case .Media:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let mediaURL : URL = arrDataList[indexPath.row].url!
            
            cell.imageView?.image = getFileIcon(for: mediaURL.absoluteString)
            cell.textLabel?.text = mediaURL.lastPathComponent
            cell.detailTextLabel?.text = fileSize(url: mediaURL)
            
            cell.selectionStyle = .gray
            return cell
            
        case .Links:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatAttachMedia_DocsCell") as! ChatAttachMedia_DocsCell
            
            //let strLinkURL = arrDataList[indexPath.row]
            let strLinkURL = objMediaContent.arrLinks[indexPath.row]
            
            let arrMedia = strLinkURL.components(separatedBy: kLinkMessageSeparator)
            let linkURL = arrMedia[0]
            let linkImage = arrMedia[1]
            let linkTitle = arrMedia[2]
            var linkDesc = "-"
            if arrMedia.count > 3 { linkDesc = arrMedia[3] }
            
            cell.imgLogo.contentMode = .scaleAspectFit
            cell.imgLogo.image = #imageLiteral(resourceName: "countrycode_textbox")
            cell.imgLogo.sd_setImage(with: linkImage.toUrl, completed: { (image, error, cacheType, url) in
                if error != nil { cell.imgLogo.image = #imageLiteral(resourceName: "countrycode_textbox") }
                else { cell.imgLogo.image = image }
            })
            
            cell.lblName.text = linkTitle
            cell.lblSize.text = linkURL
            cell.lblDateTime.text = linkDesc
            
            cell.selectionStyle = .gray
            return cell
            
        case .Docs:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatAttachMedia_DocsCell") as! ChatAttachMedia_DocsCell
            
            let objDocInfo : objDocumentInfo = objMediaContent.arrDocument[indexPath.row]
            
            cell.imgLogo.image = getFileIcon(for: objDocInfo.strURL)
            cell.lblName.text = objDocInfo.name
            
            var createDateoffile = ""
            createDateoffile = objDocInfo.createDate
            createDateoffile = createDateoffile.count == 0 ? "" : "• \(createDateoffile)"
            cell.lblSize.text = "\(objDocInfo.size) \(createDateoffile)"
            cell.lblDateTime.text = objDocInfo.type
            
            cell.selectionStyle = .none
            return cell
            
            
        default:
            return UITableViewCell.init()
        }
        //return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblChatAttachMedia.deselectRow(at: indexPath, animated: true)
        
        switch objEnumAttachMedia {
        case .Media:
            //mediaURL = arrDataList[indexPath.row].url!
            break
            
        case .Links:
            //var strMediaURL = arrDataList[indexPath.row]
            var strMediaURL = objMediaContent.arrLinks[indexPath.row]
            let arrMedia = strMediaURL.components(separatedBy: kLinkMessageSeparator)
            strMediaURL = arrMedia[0]
            
            let arrURLContent = strMediaURL.components(separatedBy: "//")
            if (arrURLContent.first?.uppercased() != "https://".uppercased()) {
                strMediaURL = "https://\(strMediaURL)"
            }
            
            //Open URL in Browser
            if let url = URL(string: strMediaURL) {
                 if #available(iOS 10.0, *) { UIApplication.shared.open(url, options: [:], completionHandler: nil) }
                 else { UIApplication.shared.openURL(url) }
            }
            else { showMessage("Something was wrong!\n Invalid URL") }
            return
        case .Docs:
            
            let objDocInfo : objDocumentInfo = objMediaContent.arrDocument[indexPath.row]
            let mediaURL = objDocInfo.strURL
            
            if isPathForAudio(path: mediaURL) {
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
                vc.modalPresentationStyle = .overCurrentContext
                vc.audioURL = mediaURL
                vc.URL_CurrentDir = self.URL_CurrentDir
                present(vc, animated: true, completion: nil)
            }
            else {
                //Manage : Contact, TXT
                documentInteraction = UIDocumentInteractionController()
                documentInteraction = UIDocumentInteractionController.init(url: mediaURL.url!)
                documentInteraction.delegate = self
                documentInteraction.name = objDocInfo.name
                let success = documentInteraction.presentPreview(animated: true)
                if success == false {
                    //print("//OPEN AS MENU")
                    documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
            }
            break
            
        default:
            break
        }
        
        /*
        //if isPathForImage(path: .absoluteString) { }
        //else if isPathForVideo(path: localURL.path) { }
        if isPathForAudio(path: mediaURL.absoluteString) {
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.audioURL = mediaURL.absoluteString
            //vc.URL_CurrentDir = self.get_URL_inChatDir()
            present(vc, animated: true, completion: nil)
        }
        else if isPathForContact(path: mediaURL.absoluteString)
        {
            //var documentInteraction = UIDocumentInteractionController()
            documentInteraction = UIDocumentInteractionController()
            documentInteraction = UIDocumentInteractionController.init(url: mediaURL)
            documentInteraction.delegate = self
            let success = documentInteraction.presentPreview(animated: true)
            if success == false{
                //print("//OPEN AS MENU")
                documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            }
        }*/
    }
    
    // MARK: - Document present delegate method
    internal func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return mostTopViewController!
    }
}
