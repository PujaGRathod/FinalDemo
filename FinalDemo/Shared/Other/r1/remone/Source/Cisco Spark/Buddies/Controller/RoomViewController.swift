// Copyright 2016-2017 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SparkSDK
import ObjectMapper
import Cartography
import Photos
import MobileCoreServices
import IQKeyboardManagerSwift

class RoomViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MessageTableCellDelegate {

    let refreshInterval: TimeInterval = 2

    // MARK: UI variables
    private var messageTableView: UITableView?
    var roomModel: RoomModel?
    private var localGroupModel: GroupModel?
    private var roomMemberTableView: UITableView?
    private var maskView: UIView?
    private var roomMeberList: [Membership] = []
    private var messageList: [MessageModel] = []
    private let messageTableViewHeight = (Constants.Size.screenHeight-64-40)
    private var tableTap: UIGestureRecognizer?
    private var topIndicator: UIActivityIndicatorView?
    private var navigationTitleLabel: UILabel?
    private var buddiesInputView : BuddiesInputView?
    private var sparkFile : SparkFile?
    private var isloadingData: Bool = false

    private var timerRefresh: Timer?

    // MARK: - Life Circle
    init(room: RoomModel) {
        super.init()
        self.roomModel = room
        self.localGroupModel = User.CurrentUser[(self.roomModel?.localGroupId)!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainController?.tabBarController?.tabBar.isHidden = true
        self.setUpTopNavigationView()
        self.setUpSupViews()
        self.addbackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(messageNotiReceived(noti:)), name: NSNotification.Name(rawValue: MessageReceptionNotificaton), object: nil)
        self.timerRefresh = Timer.scheduledTimer(timeInterval: self.refreshInterval, target: self, selector: #selector(self.loadLatestMessages), userInfo: nil, repeats: true)
        //        self.requestMessageList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timerRefresh?.invalidate()
        self.timerRefresh = nil
    }

    @objc func messageNotiReceived(noti: Notification) {
        if let paramDict = noti.object as? [String: String],
            let fromEmail = paramDict["from"],
            let localGroup = User.CurrentUser.getSingleGroupWithContactEmail(email: fromEmail) {
            if(localGroup.groupId == self.localGroupModel?.groupId){
                localGroup.unReadedCount = 0
                if(self.roomModel?.roomId != nil) {
                    self.requestRecivedMessages()
                }
            }
        }
    }

    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        self.isloadingData = true
        self.timerRefresh?.invalidate()
        self.timerRefresh = nil
        if self.navigationController?.presentingViewController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func addbackButton() {
        let backBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backBtn.tintColor = .white
        self.navigationItem.leftBarButtonItem = backBtn
    }

    func loadPrevious() {
        if let roomID = self.roomModel?.roomId,
            let first = self.messageList.first?.messageId,
            !self.isloadingData {
            self.topIndicator?.startAnimating()
            self.isloadingData = true
            self.navigationTitleLabel?.text = ""
                SparkSDK?.messages.list(roomId: roomID, beforeMessage: first, max: 40, queue: DispatchQueue.global(qos: .background), completionHandler: { (response: ServiceResponse<[Message]>) in
                    DispatchQueue.main.async {
                        self.topIndicator?.stopAnimating()
                    }
                    self.isloadingData = false
                    switch response.result {
                    case .success(let value):
                        print(value)
                        for message in value {
                            if let msgModel = MessageModel(message: message) {
                                msgModel.messageState = MessageState.received
                                msgModel.localGroupId = self.roomModel?.localGroupId
                                if(msgModel.text == nil){
                                    msgModel.text = ""
                                }
                                self.messageList.insert(msgModel, at: 0)
                            }
                        }
                        DispatchQueue.main.async {
                            self.updateNavigationTitle()
                            self.messageTableView?.reloadData()
                        }

                    case .failure:
                        DispatchQueue.main.async {
                            self.updateNavigationTitle()
                        }
                        break
                    }
                })
        }
    }

    // MARK: - SparkSDK: lising message/ligsting member in a room
    func requestMessageList() {
        if(self.roomModel?.roomId == nil || self.roomModel?.roomId.length == 0) {
            self.updateNavigationTitle()
            //            return;
        }
        if self.isloadingData {
            return;
        }
        self.isloadingData = true
        if let roomid = self.roomModel?.roomId {
            self.topIndicator?.startAnimating()
            SparkSDK?.messages.list(roomId: roomid, before: nil, beforeMessage: nil, max: 40, queue: DispatchQueue.global(qos: .background), completionHandler: { (response: ServiceResponse<[Message]>) in
                switch response.result {
                case .success(let value):
                    print(value)
                    self.messageList.removeAll()
                    for message in value{
                        if let msgModel = MessageModel(message: message) {
                            msgModel.messageState = MessageState.received
                            msgModel.localGroupId = self.roomModel?.localGroupId
                            if(msgModel.text == nil){
                                msgModel.text = ""
                            }
                            self.messageList.insert(msgModel, at: 0)
                        }
                    }
                    DispatchQueue.main.async {
                        self.topIndicator?.stopAnimating()
                        self.isloadingData = false
                        self.updateNavigationTitle()
                        self.messageTableView?.reloadData()
                        if(self.messageList.count > 0){
                            let indexPath = IndexPath(row: self.messageList.count-1, section: 0)
                            self.messageTableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        }
                        //                    self.perform(#selector(self.loadLatestMessages), with: nil, afterDelay: self.refreshInterval)
                    }

                case .failure:
                    DispatchQueue.main.async {
                        self.topIndicator?.stopAnimating()
                        self.isloadingData = false
                        self.updateNavigationTitle()
                    }
                    break
                }
            })
        }
    }

    @objc func loadLatestMessages() {
        if(self.roomModel?.roomId == nil || self.roomModel?.roomId.length == 0) {
            self.updateNavigationTitle()
            return;
        }
        if self.isloadingData {
            return;
        }
        self.isloadingData = true
        if let roomid = self.roomModel?.roomId {
        SparkSDK?.messages.list(roomId: roomid, max: 10, queue: DispatchQueue.global(qos: .background), completionHandler: { (response: ServiceResponse<[Message]>) in
            self.isloadingData = false
            switch response.result {
            case .success(let value):
                print(value)
                var newMessages = [MessageModel]()
                for message in value {
                    if let msgModel = MessageModel(message: message) {
                        msgModel.messageState = MessageState.received
                        msgModel.localGroupId = self.roomModel?.localGroupId
                        if(msgModel.text == nil){
                            msgModel.text = ""
                        }
                        if !self.messageList.contains(msgModel) {
                            newMessages.append(msgModel)
                        }
                    }
                }
                if newMessages.count > 0 {
                    self.messageList.append(contentsOf: newMessages)
                    DispatchQueue.main.async {
                        self.updateNavigationTitle()
                        self.messageTableView?.reloadData()
                        if(self.messageList.count > 0){
                            let indexPath = IndexPath(row: self.messageList.count-1, section: 0)
                            self.messageTableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        }
                        //                        self.perform(#selector(self.loadLatestMessages), with: nil, afterDelay: self.refreshInterval)
                    }
                } else {
                    DispatchQueue.main.async {
                        //                        self.perform(#selector(self.loadLatestMessages), with: nil, afterDelay: self.refreshInterval)
                    }
                }

            case .failure:
                DispatchQueue.main.async {
                    self.updateNavigationTitle()
                }
                break
            }
        })
        }
    }

    func requestRecivedMessages() {
        self.loadLatestMessages()
        //        self.topIndicator?.startAnimating()
        //        self.navigationTitleLabel?.text = ""
        //        SparkSDK?.messages.list(roomId: (self.roomModel?.roomId)!, max: 1, queue: nil, completionHandler: { (response: ServiceResponse<[Message]>) in
        //            self.topIndicator?.stopAnimating()
        //            switch response.result {
        //            case .success(let value):
        //                print(value)
        //                for message in value{
        //                    if let msgModel = MessageModel(message: message) {
        //                        msgModel.messageState = MessageState.received
        //                        msgModel.localGroupId = self.roomModel?.localGroupId
        //                        if(msgModel.text == nil) {
        //                            msgModel.text = ""
        //                        }
        //                        self.messageList.append(msgModel)
        //                    }
        //                }
        //                self.messageTableView?.reloadData()
        //                if(self.messageList.count > 0){
        //                    let indexPath = IndexPath(row: self.messageList.count-1, section: 0)
        //                    self.messageTableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        //                }
        //                self.updateNavigationTitle()
        //                break
        //            case .failure:
        //                self.updateNavigationTitle()
        //                break
        //            }
        //        })
    }
    
    func requestRoomMemberList() {
        KTActivityIndicator.singleton.show(title: "Loading")
        SparkSDK?.memberships.list(roomId: (self.roomModel?.roomId)!, queue: DispatchQueue.global(qos: .background)) { (response: ServiceResponse<[Membership]>) in
            DispatchQueue.main.async {
                KTActivityIndicator.singleton.hide()
                switch response.result {
                case .success(let value):
                    self.roomMeberList.removeAll()
                    for memberShip in value {
                        self.roomMeberList.append(memberShip)
                    }
                    self.roomMemberTableView?.reloadData()

                case .failure:
                    self.roomMemberTableView?.reloadData()
                }
            }
        }
    }
    
    func sendMessage(text: String) {
        if APIManager.shared.isConnectedToInternet {
            if text.trimString() == "" {
                return;
            }
            let tempMessageModel = MessageModel()
            tempMessageModel.roomId = self.roomModel?.roomId
            tempMessageModel.messageState = MessageState.willSend
            tempMessageModel.personId = User.CurrentUser.id
            tempMessageModel.personEmail = EmailAddress.fromString(User.CurrentUser.email)
            tempMessageModel.text = text.trimString()
            tempMessageModel.created = Date.init()
            tempMessageModel.localGroupId = self.roomModel?.localGroupId
            
            if (self.localGroupModel?.groupType == .singleMember) {
                tempMessageModel.toPersonEmail = EmailAddress.fromString((self.localGroupModel?[0]?.email)!)
            }
            if !self.messageList.contains(tempMessageModel) {
                self.messageList.append(tempMessageModel)
                self.messageTableView?.insertRows(at: [IndexPath(row: self.messageList.count-1, section: 0)], with: .bottom)
                self.buddiesInputView?.inputTextView?.text = ""
                let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
                if indexPath.row < (self.messageTableView?.numberOfRows(inSection: 0) ?? 0) {
                    self.messageTableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            } else {
                self.messageList = self.messageList.uniqueElements
                self.messageTableView?.reloadData()
            }
            return;
        } else {
            let alertController = UIAlertController(title: "", message: "There is no Internet connection.".localized, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UI Implementation
    private func setUpTopNavigationView(){

        if(self.navigationTitleLabel == nil){
            self.navigationTitleLabel = UILabel(frame: CGRect(0,0,Constants.Size.screenWidth-80,20))
            self.navigationTitleLabel?.font = Constants.Font.NavigationBar.Title
            self.navigationTitleLabel?.textColor = UIColor.white
            self.navigationTitleLabel?.textAlignment = .center
            self.navigationItem.titleView = self.navigationTitleLabel
            self.topIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            self.topIndicator?.hidesWhenStopped = true
            self.navigationTitleLabel?.addSubview(self.topIndicator!)
            self.topIndicator?.center = CGPoint((self.navigationTitleLabel?.center.x)!-20, 15)
        }

        self.requestMessageList()
    }

    private func setUpSupViews(){
        self.updateBarItem()
        self.setUpMessageTableView()
        self.setUpBottomView()
    }
    
    private func updateBarItem() {
        var avator: UIImageView?
        if (User.CurrentUser.loginType != .None) {
            avator = User.CurrentUser.avator
            if let avator = avator {
                avator.setCorner(Int(avator.frame.height / 2))
            }
            let membersBtnItem = UIBarButtonItem(image: UIImage(named: "icon_members"), style: .plain, target: self, action: #selector(membersBtnClicked))
            self.navigationItem.rightBarButtonItem = membersBtnItem
        }
    }

    private func setUpMessageTableView(){
        if(self.messageTableView == nil){
            self.messageTableView = UITableView(frame: CGRect(0,0,Int(Constants.Size.screenWidth),Int(messageTableViewHeight)))
            self.messageTableView?.separatorStyle = .none
            self.messageTableView?.backgroundColor = Constants.Color.Theme.Background
            self.messageTableView?.delegate = self
            self.messageTableView?.dataSource = self
            self.messageTableView?.alwaysBounceVertical=true
            self.view.addSubview(self.messageTableView!)
        }
    }
    
    private func setUpBottomView(){
        let bottomViewWidth = Constants.Size.screenWidth
        self.buddiesInputView = BuddiesInputView(frame: CGRect(x: 0, y: messageTableViewHeight, width: bottomViewWidth, height: 40) , tableView: self.messageTableView!)
        self.buddiesInputView?.sendBtnClickBlock = { (textStr: String) in
            self.sendMessage(text: textStr)
        }
        self.buddiesInputView?.plusBtnClickBlock = { (textStr: String) in
            self.setUpActionSheet()
        }
        self.view.addSubview(self.buddiesInputView!)
    }
    
    private func setUpMembertableView(){
        if(self.roomMemberTableView == nil){
            self.roomMemberTableView = UITableView(frame: CGRect(Constants.Size.screenWidth, 0, Constants.Size.screenWidth / 4 * 3, Constants.Size.screenHeight + 20))
            self.roomMemberTableView?.separatorStyle = .none
            self.roomMemberTableView?.backgroundColor = Constants.Color.Theme.Background
            self.roomMemberTableView?.delegate = self
            self.roomMemberTableView?.dataSource = self
        }
    }

    private func setUpActionSheet(){
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localized, style: .default) { (_) in
            if (UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                self.present(picker, animated:true, completion: {
                })
            }
            else
            {
                self.showAlert("Camera inaccessable".localized, message:"")
            }
        }
        let photoLibraryAction = UIAlertAction(title: "Device photo library".localized, style: .default) { (_) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated:true, completion: {
            })
        }
        let Document = UIAlertAction(title: "Document file".localized, style: .default) { (_) in
            let arrKUTType:[String] = [
                String(kUTTypePDF),
                String(kUTTypeBMP),
                String(kUTTypeGIF),
                String(kUTTypeRTF),
                String(kUTTypePNG),
                String(kUTTypeJPEG),
                String(kUTTypeJPEG2000),
                String(kUTTypeMP3),
                String(kUTTypeMPEG),
                String(kUTTypeMPEG4),
                String(kUTTypeMPEG4Audio),
                String(kUTTypeImage),
                String(kUTTypeICO),
                String(kUTTypeText),
                String(kUTTypePlainText),
                String(kUTTypeVideo),
                String(kUTTypeMovie),
                String(kUTTypeQuickTimeImage),
                String(kUTTypeQuickTimeMovie),
                "com.microsoft.word.doc",
                "org.openxmlformats.wordprocessingml.document",
                "org.oasis-open.opendocument.text-template"]

            let importMenu = UIDocumentMenuViewController(documentTypes: arrKUTType, in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in }
        cameraAction.setValue(#imageLiteral(resourceName: "imgCamera").withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
        photoLibraryAction.setValue(#imageLiteral(resourceName: "imgGallery").withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
        Document.setValue(#imageLiteral(resourceName: "imgDocument").withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(Document)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: {
        })
        
    }
    
    func uploadFiles(_ dataDic: [String:Any],fileData:Data) {
        self.showLoader()
        APIManager.shared.uploadFiles(dataDic, fileData: fileData) { (response) in
            self.hideLoader()
            self.requestMessageList()
        }
    }
    
    private func setUpMaskView(){
        if(self.maskView == nil){
            self.maskView = UIView(frame: CGRect.zero)
            self.maskView?.frame = CGRect(x: 0, y: 0, width: Constants.Size.screenWidth, height: Constants.Size.screenHeight)
            self.maskView?.backgroundColor = UIColor.black
            self.maskView?.alpha = 0
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMemberTableView))
            self.maskView?.addGestureRecognizer(tap)
        }
    }
    
    @objc private func membersBtnClicked(){
        self.buddiesInputView?.inputTextView?.resignFirstResponder()
        self.slideMembersTableView()
    }
    
    @objc public func slideMembersTableView() {
        self.setUpMaskView()
        self.setUpMembertableView()
        self.navigationController?.view.addSubview(self.maskView!)
        self.navigationController?.view.addSubview(self.roomMemberTableView!)
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.roomMemberTableView?.transform = CGAffineTransform(translationX: -Constants.Size.screenWidth/4*3, y: 0)
            self.maskView?.alpha = 0.4
        }) { (_) in
            self.requestRoomMemberList()
        }
        
    }

    @objc public func dismissMemberTableView(){
        UIView.animate(withDuration: 0.2, animations: {
            self.roomMemberTableView?.transform = CGAffineTransform(translationX:0, y: 0)
            self.maskView?.alpha = 0
        }) { (complete) in
            self.maskView?.removeFromSuperview()
            self.roomMemberTableView?.removeFromSuperview()
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.roomMemberTableView) {
            return CGFloat(membershipTableCellHeight)
        } else {
            var fileCount = 0
            if(self.messageList[indexPath.row].files != nil){
                fileCount = (self.messageList[indexPath.row].files?.count)!
            }
            let cellHeight = MessageTableCell.getCellHeight(text: self.messageList[indexPath.row].text!, imageCount: fileCount)
            return cellHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.roomMemberTableView){
            return self.roomMeberList.count
        }else{
            return self.messageList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.roomMemberTableView) {
            let index = indexPath.row
            let memberModel = self.roomMeberList[index]
            var reuseCell = tableView.dequeueReusableCell(withIdentifier: "PeopleListTableCell")
            if reuseCell != nil {
                (reuseCell as! PeopleListTableCell).updateMembershipCell(newMemberShipModel: memberModel)
            } else {
                reuseCell = PeopleListTableCell(membershipModel: memberModel)
            } 
            return reuseCell!
        } else {
            let index = indexPath.row
            let messageModel = self.messageList[index]
            var reuseCell = tableView.dequeueReusableCell(withIdentifier: "MessageTableCell") as? MessageTableCell
            if reuseCell == nil {
                reuseCell = MessageTableCell(messageModel: messageModel)
            }
            reuseCell?.delegate = self

            return reuseCell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == self.roomMemberTableView){
            return 64
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == self.roomMemberTableView){
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.Size.screenWidth/4*3, height: 64))
            headerView.backgroundColor = Constants.Color.Theme.Main
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: headerView.frame.size.height))
            label.text = "Members"
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = Constants.Font.NavigationBar.Title
            headerView.addSubview(label)
            return headerView
        } else {
            return nil
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView == self.roomMemberTableView) {
            
        } else {

        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let currentOffset = scrollView.contentOffset.y
            if currentOffset <= -100.0 {
                self.loadPrevious()
            }
        }
    }

    func openFile(_ file: SparkFile) {
        MediaViewerVC.loadFile(file, on: self)
    }
    
    func showErrorMsg(strErrorMsg: String) {
        
        let alertController = UIAlertController(title: "", message: strErrorMsg, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
            if self.navigationController?.presentingViewController != nil {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: Other Functions
    private func updateNavigationTitle() {
        self.navigationTitleLabel?.text = self.roomModel?.title != nil ? self.roomModel?.title! : "No Name"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension RoomViewController: UIDocumentMenuDelegate, UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let url = url as URL
        print("The Url is : \(url)")
        var fileData:Data?
        do {
            fileData = try Data(contentsOf: url)
            
        } catch {
            print(error.localizedDescription)
        }
        
        var dicFileData:[String:Any] = [:]
        dicFileData["filepath"] = url.absoluteString
        dicFileData["roomId"] = self.roomModel?.roomId
        dicFileData["text"] = self.buddiesInputView?.inputTextView?.text
        
        var authenticator = SparkSDK?.authenticator
        authenticator = SparkSDK?.authenticator as! OAuthAuthenticator
        authenticator?.accessToken(completionHandler: { (token) in
            dicFileData["token"] = "Bearer \(token!)"
        })
        if fileData != nil
        {
            self.uploadFiles(dicFileData, fileData: fileData!)
        }
    }

    public func documentMenu(_ documentMenu:     UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("we cancelled")
        dismiss(animated: true, completion: nil)
    }
}

extension RoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var fileData:Data?
        var strDirectoryPath:String = ""
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            do {
                fileData = try Data(contentsOf: videoURL)
            } catch {
                print(error.localizedDescription)
            }
            strDirectoryPath = videoURL.absoluteString
        } else {
            if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let fileName = String(Int(NSDate().timeIntervalSince1970)).appending(".jpg")
                fileData = UIImageJPEGRepresentation(img, 1.0)
                if fileData != nil {
                    self.sparkFile = SparkFile.init(with:"", data: fileData!, mime:MimeType.image , fileName: fileName)
                    strDirectoryPath = (self.sparkFile?.localURL?.absoluteString)!
                }
            }
        }
        var dicFileData:[String:Any] = [:]
        dicFileData["filepath"] = strDirectoryPath
        dicFileData["roomId"] = self.roomModel?.roomId
        dicFileData["text"] = self.buddiesInputView?.inputTextView?.text
        var authenticator = SparkSDK?.authenticator
        authenticator = SparkSDK?.authenticator as! OAuthAuthenticator
        authenticator?.accessToken(completionHandler: { (token) in
            dicFileData["token"] = "Bearer \(token!)"
        })
        if fileData != nil {
            self.uploadFiles(dicFileData, fileData: fileData!)
        }
        dismiss(animated: true) {

        }
    }
}

//MARK: - Open Room methods
extension RoomViewController {

    class func showMessageFromNotification(contact:Contact? = nil, on vc: UINavigationController) {
        if (User.CurrentUser.loginType == .User) {
            if let contact = contact {
                if (User.CurrentUser.rooms.count > 0) {
                    var objRoomModel: RoomModel?
                    if let group = User.CurrentUser.getSingleGroupWithContactId(contactId: contact.id),
                        let groupID = group.groupId,
                        group.groupType == .singleMember {
                        if let roomModel = User.CurrentUser.findLocalRoomWithId(localGroupId: groupID){
                            objRoomModel = roomModel
                        }
                    } else {
                        for roomModel:RoomModel in User.CurrentUser.rooms {
                            if roomModel.type == "direct" {
                                if let roomMembers  = roomModel.roomMembers {
                                    for roomMem:Contact in roomMembers {
                                        if roomMem.email  == contact.email {
                                            objRoomModel = roomModel
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if let objRoomModel = objRoomModel {
                        RoomViewController.showMessageRoom(with:objRoomModel, contact:nil, strName: contact.name, on: vc)
                    } else {
                        RoomViewController.showMessageRoom(with:nil, contact: contact, strName: contact.name, on: vc)
                    }
                } else {
                    RoomViewController.showMessageRoom(with:nil, contact: contact, strName: contact.name, on: vc)
                }
            }
        } else {
            //user not loggedin in spark
        }
    }

    class func showMessageRoomById(with roomId:String,on vc: UINavigationController) {
        DispatchQueue.main.async {
            KTActivityIndicator.singleton.show(title: "Loading")
        }
        SparkSDK?.rooms.get(roomId: roomId, queue: DispatchQueue.global(qos: .background), completionHandler: { (response:ServiceResponse<Room>) in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    KTActivityIndicator.singleton.hide()
                    if let room = RoomModel(room: value) {
                        if vc.topViewController?.isKind(of: RoomViewController.classForCoder()) == true,
                            let _ = vc.topViewController as? RoomViewController {

                        } else {
                            let roomVC = RoomViewController.init(room: room)
                            let nv = UINavigationController.init(rootViewController: roomVC)
                            vc.present(nv, animated: true, completion: nil)
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    print("room failer")
                    KTActivityIndicator.singleton.hide()
                    KTInputBox.alert(error: error)
                }
                break
            }
        })
    }

    class func showMessageRoom(with model: RoomModel? = nil, contact:Contact? = nil, strName: String, on vc: UINavigationController) {
        if (model == nil) {
            if let contact = contact {
                User.CurrentUser.addNewContactAsGroup(contact: contact)
                if let group = User.CurrentUser.getSingleGroupWithContactId(contactId: contact.id),
                    let groupID = group.groupId,
                    group.groupType == .singleMember {
                    let createdRoom = RoomModel(roomId: "")
                    createdRoom.localGroupId = groupID
                    createdRoom.title = contact.name
                    createdRoom.roomMembers = []
                    for contact in group.groupMembers {
                        createdRoom.roomMembers?.append(contact)
                    }
                    createdRoom.localGroupId = group.groupId!
                    User.CurrentUser.addLocalRoom(room: createdRoom)
                    User.CurrentUser.saveLocalRooms()
                    let roomVC = RoomViewController(room: createdRoom)
                    let nv = UINavigationController.init(rootViewController: roomVC)
                    vc.present(nv, animated: true, completion: nil)
                }
            }
        } else {
            if vc.topViewController?.isKind(of: RoomViewController.classForCoder()) == true,
                let _ = vc.topViewController as? RoomViewController {

            } else {
                if let model = model {
                    let roomVC = RoomViewController.init(room: model)
                    let nv = UINavigationController.init(rootViewController: roomVC)
                    vc.present(nv, animated: true, completion: nil)
                }
            }
        }
    }

    /*
     01 Mar, 18 11:49 PM
     //                let singleGroupIdStr = email.toString().md5
     //                if User.CurrentUser[singleGroupIdStr!] == nil {
     //
     ////                    User.CurrentUser.addNewContactAsGroup(contact: contact)
     //
     //                    let group = GroupModel(contact: contact)
     //                    let createdRoom = RoomModel(roomId: "")
     //                    createdRoom.localGroupId = group.groupId!
     //                    createdRoom.title = strName
     //                    createdRoom.roomMembers = []
     //                    createdRoom.roomMembers?.append(contact)
     //                    User.CurrentUser.addNewContactAsGroup(contact: contact)
     //
     //                    User.CurrentUser.addLocalRoom(room: createdRoom)
     //                    User.CurrentUser.saveLocalRooms()
     //
     //                    if vc.topViewController?.isKind(of: RoomViewController.classForCoder()) == true,
     //                        let _ = vc.topViewController as? RoomViewController {}
     //                    else
     //                    {
     //                        let roomVC = RoomViewController.init(room:createdRoom)
     //                        let nv = UINavigationController.init(rootViewController: roomVC)
     //                        vc.present(nv, animated: true, completion: nil)
     //                    }
     //
     //                } else {
     //                    if let group = User.CurrentUser.getSingleGroupWithContactId(contactId: contact.id),
     //                        let groupID = group.groupId,
     //                        group.groupType == .singleMember {
     //                        let createdRoom = RoomModel(roomId: "")
     //                        createdRoom.localGroupId = groupID
     //                        createdRoom.title = contact.name
     //                        createdRoom.roomMembers = []
     //                        for contact in group.groupMembers {
     //                            createdRoom.roomMembers?.append(contact)
     //                        }
     //                        createdRoom.localGroupId = group.groupId!
     //                        User.CurrentUser.addLocalRoom(room: createdRoom)
     //                        User.CurrentUser.saveLocalRooms()
     //                        let roomVC = RoomViewController(room: createdRoom)
     //                        let nv = UINavigationController.init(rootViewController: roomVC)
     //                        vc.present(nv, animated: true, completion: nil)
     //                    }
     //                }
     */
}
