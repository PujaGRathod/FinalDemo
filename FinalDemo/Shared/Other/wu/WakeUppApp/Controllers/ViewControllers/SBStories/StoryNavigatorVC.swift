//
//  StoryNavigatorVC.swift
//  WakeUppApp
//
//  Created by Admin on 06/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import MobileCoreServices
import  AVKit
import AVFoundation
import Photos
class StoryNavigatorVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrStory = [StoryListModel]()
    
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (CubeAttributesAnimator(), true, 1, 1)
    var direction: UICollectionViewScrollDirection = .horizontal
    
    var interactor:Interactor? = nil
    
    var isviewtapped = false
    var isMyStory = false
    var currentStories = [StructStatusStory]()
    var redirectFrom = ""
    var selectedRow = Int()
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStatusBarHidden = true
        self.layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if redirectFrom == "FriendStory" {
            if selectedRow > 0{
                DispatchQueue.main.async{
                    let ipath = IndexPath.init(item: self.selectedRow, section: 0)
                    self.collectionView.scrollToItem(at: ipath, at: .centeredHorizontally, animated: false)
                }
            }
        }
        else
        {
            if redirectFrom == "MyStory"
            {
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isStatusBarHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_DisableScroll), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_UnableScroll), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_UserStoryFinished), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_GoBackStory), object: nil)
    }
    @objc func scrollEnable()
    {
        self.collectionView.isScrollEnabled = true
    }
    @objc func scrollDisable()
    {
        self.collectionView.isScrollEnabled = false
    }
    
    @objc func userStoryFinished()
    {
        let visibleIndexPath = getVisibleCellIndexPath()
        let cell = self.collectionView.cellForItem(at: visibleIndexPath) as! StoryCell
        postNotification(with: NC_FriendStoryRefresh, andUserInfo: ["uid":cell.currentStories.userID])
        if(arrStory.count == ((visibleIndexPath.row) + 1)) {
            // //print("STORIES FINISHED : DISMISSING NOW")
            APP_DELEGATE.cancelAllDownloadRequest()
            dismiss(animated: true, completion: nil)
        }else{
            //  //print("MOVING TO NEXT STORY")
            let nextIndexPath = IndexPath.init(row: ((visibleIndexPath.row) + 1), section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func goBackStory(){
        let visibleIndexPath = getVisibleCellIndexPath()
        if visibleIndexPath.row == 0{
            //print("First Story")
        }else{
            let previousIndexPath = IndexPath.init(row: ((visibleIndexPath.row) - 1), section: 0)
            collectionView.scrollToItem(at: previousIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func getVisibleCellIndexPath()->IndexPath{
        var visibleRect: CGRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)!
    }
    
    func layoutUI()
    {
        collectionView.register(UINib.init(nibName: "StoryCell", bundle: nil), forCellWithReuseIdentifier: "StoryCell")
        collectionView?.isPagingEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = direction
            layout.animator = animator.0
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(userStoryFinished), name: Notification.Name(NC_UserStoryFinished), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollEnable), name: Notification.Name(NC_UnableScroll), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollDisable), name: Notification.Name(NC_DisableScroll), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goBackStory), name: Notification.Name(NC_GoBackStory), object: nil)
    }
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold:CGFloat = 0.3
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            
            /*interactor.shouldFinish
             ? interactor.finish()
             : interactor.cancel()*/
            
            if interactor.shouldFinish{
                interactor.finish()
                self.collectionView.visibleCells.forEach({ (storyCell) in
                    (storyCell as! StoryCell).removeSPBDelegate()
                    (storyCell as! StoryCell).pausePlayer()
                })
                //(self.collectionView.visibleCells.first! as! StoryCell).spb.delegate = nil
            }else{
                interactor.cancel()
            }
            
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension StoryNavigatorVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell
        cell.currentStories = arrStory[indexPath.row]
        cell.isMine = isMyStory
        cell.isViewTapped = self.isviewtapped
        if isMyStory == true {
            cell.selectedIndex = selectedRow
        }
        else {
            cell.selectedIndex = 0
        }
        var url = cell.currentStories.profileURL
        if url.count > 0 && url.hasPrefix("http") == false {
            //print("DO NOW")
            url = Get_Profile_Pic_URL + url
        }
        
        cell.btnProfile.sd_setBackgroundImage(with: url.toUrl, for: .normal, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: nil)
        cell.btnMenu.tag = indexPath.item
        cell.storyCellDelegate = self
        return cell
    }
    
    @IBAction func btnseenstoryclicked(_ sender: UIButton)
    {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStory.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // let size = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        let size = CGSize(width: view.bounds.width / CGFloat(animator.2), height: view.bounds.height / CGFloat(animator.3))
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let storyCell = cell as! StoryCell
        storyCell.removeSPBDelegate()
        storyCell.pausePlayer()
    }
    
    
}
extension StoryNavigatorVC
{
    func callcopyStory(_ imgs:String, _ durations:String , _ types : String,copydone:@escaping (Bool)->())
    {
        showHUD()
        var strlist = ""
        if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "3"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status_Useridlist)
        }
        else if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "4"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kOnlySharewith_Useridlist)
        }
        else
        {
            strlist = ""
        }
        let dic = [
            "images":imgs,
            "durations":durations,
            "types":types,
            "user_id": UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "allowcopy":"0",
            "storycaption":"",
            "statusviewprivacy": UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status),
            "markedidlist":strlist
            ] as [String : Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyCreateStory,dic).timingOut(after: 30) {data in
            let data = data as Array
            if(data.count > 0)
            {
                let data = data as Array
                if(data.count > 0)
                {
                    if data[0] is String{
                        return
                    }
                    let dic = data[0] as! NSDictionary
                    if dic.value(forKey: "success") as! String == "1"
                    {
                        postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                        showStatusBarMessage("Story can see in you story list now.")
                    }
                    else
                    {
                        showStatusBarMessage("Problem while coping story")
                    }
                }
                copydone(true)
                hideHUD()
            }
            else
            {
                copydone(true)
            }
        }
    }
}
extension StoryNavigatorVC:StoryCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func showImagePicker(_ sender: UIButton) {
        
    }
    
    func btnMenuClicked(_ sender:UIButton)
    {
        if isMyStory == false
        {
            let cell = self.collectionView.cellForItem(at: IndexPath.init(item: sender.tag, section: 0))  as! StoryCell
            cell.spb.isPaused = true
            cell.pausePlayer()
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionReport = UIAlertAction.init(title: "Make it as my story", style: .default)
            { (action) in
                let photonm = cell.currentStories.arrStories[sender.tag].mediaURL.toUrl?.lastPathComponent
                print(photonm ?? "")
                self.callcopyStory(photonm!, cell.currentStories.arrStories[sender.tag].duration, cell.currentStories.arrStories[sender.tag].storyType, copydone: { (isdone) in
                    cell.spb.isPaused = false
                    cell.resumePlayer()
                })
            }
            alert.addAction(actionReport)
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            }
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let cell = self.collectionView.cellForItem(at: IndexPath.init(item: sender.tag, section: 0))  as! StoryCell
            cell.spb.isPaused = true
            cell.pausePlayer()
            var allowcopy = "0";
            let str = CoreDBManager.sharedDatabase.checkCopyStatus(sender.accessibilityLabel!)
            if str == "1"
            {
                allowcopy = "0";
            }
            else
            {
                allowcopy = "1";
            }
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionReport = UIAlertAction.init(title: "Delete", style: .default)
            { (action) in
                showHUD()
                let dic = [ "status_ids" : sender.accessibilityLabel! ] as [String : Any]
                APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyDeleteStory,dic).timingOut(after: 30) {data in
                    let data = data as Array
                    hideHUD()
                    if(data.count > 0)
                    {
                        CoreDBManager.sharedDatabase.deleteStories(byStoryIDs: [sender.accessibilityLabel!])
                        postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                        postNotification(with: NC_ViewerRefresh)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            showStatusBarMessage("Story Deleted.")
                            // self.collectionView.reloadItems(at: [IndexPath.init(item: sender.tag, section: 0)])
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            alert.addAction(actionReport)
            let actionReport2 = UIAlertAction.init(title: allowcopy == "1" ? "Enable Copy" : "Disable Copy", style: .default)
            { (action) in
                showHUD()
                let parameter:NSDictionary = ["service":APIUpdateStatusSetting,
                                              "request":["status_id": sender.accessibilityLabel! ,
                                                         "allowcopy": allowcopy],
                                              "auth" : getAuthForService()]
                HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateStatusSetting, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
                    
                    if error != nil {
                        showMessage("\(error?.localizedDescription ?? ServerResponseError)")
                        return
                    }
                    else
                    {
                        if Int(apistatus) == 0 {
                            showMessage(statusmessage)
                        }
                        else {
                            CoreDBManager.sharedDatabase.udpateStoryCopyflag(sender.accessibilityLabel!,allowcopy)
                            postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                            postNotification(with: NC_ViewerRefresh)
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                showStatusBarMessage("Story copy status changed.")
                                // self.collectionView.reloadItems(at: [IndexPath.init(item: sender.tag, section: 0)])
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    hideHUD()
                })
            }
            alert.addAction(actionReport2)
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                cell.spb.isPaused = false
                cell.resumePlayer()
            }
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func btnDeleteStoreClicked(_ sender: UIButton) {
        let cell = self.collectionView.cellForItem(at: IndexPath.init(item: sender.tag, section: 0))  as! StoryCell
        cell.spb.isPaused = true
        cell.pausePlayer()
        
        let alert = UIAlertController.init(title: "Delete Status", message: "Are you sure you went to delete this status", preferredStyle: .actionSheet)
        let actionReport = UIAlertAction.init(title: "Delete", style: .destructive)
        { (action) in
            //cell.spb.isPaused = false
            //cell.resumePlayer()
            
            showHUD()
            let dic = [ "status_ids" : sender.accessibilityLabel! ] as [String : Any]
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyDeleteStory,dic).timingOut(after: 30) {data in
                let data = data as Array
                hideHUD()
                if(data.count > 0)
                {
                    CoreDBManager.sharedDatabase.deleteStories(byStoryIDs: [sender.accessibilityLabel!])
                    postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                    postNotification(with: NC_ViewerRefresh)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        showStatusBarMessage("Story Deleted.")
                        // self.collectionView.reloadItems(at: [IndexPath.init(item: sender.tag, section: 0)])
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        alert.addAction(actionReport)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            cell.spb.isPaused = false
            cell.resumePlayer()
        }
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }

    func btncameraclicked(_ sender: UIButton)
    {
        // let tagv = sender.accessibilityLabel?.int
        
        self.imagePicker.accessibilityValue = sender.accessibilityValue
        self.imagePicker.accessibilityLabel = sender.accessibilityLabel
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .camera
        self.imagePicker.mediaTypes = [kUTTypeImage as String]
        mostTopViewController?.present(self.imagePicker, animated: true, completion: nil)
    }
    func btngalleryclicked(_ sender: UIButton)
    {
        //let tagv = sender.accessibilityLabel?.int
        
        self.imagePicker.accessibilityValue = sender.accessibilityValue
        self.imagePicker.accessibilityLabel = sender.accessibilityLabel
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .savedPhotosAlbum
        self.imagePicker.mediaTypes = [kUTTypeImage as String]
        mostTopViewController?.present(self.imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let img = UIImage.init(data: UIImageJPEGRepresentation(pickedImage,uploadImageCompression)!)
            img?.accessibilityLabel = "IMAGE"
            let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: "idStoryPreviewVC") as! StoryPreviewVC
            vc.arrimages = [img!]
            vc.timechoosen = ""
            vc.isprivate = "1"
            vc.redirectfrom = "storyreply"
            vc.storyownerid = self.imagePicker.accessibilityLabel!
            vc.storymsgformat = self.imagePicker.accessibilityValue!
            APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        }
        
        mostTopViewController?.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
        APP_DELEGATE.appNavigation?.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

