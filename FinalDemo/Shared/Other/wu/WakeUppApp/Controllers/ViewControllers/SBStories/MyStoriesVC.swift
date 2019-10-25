//
//  MyStoriesVC.swift
//  WakeUppApp
//
//  Created by Admin on 06/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class MyStoriesVC: UIViewController {
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet var tblView: UITableView!
    
    var arrMyStories = [StructStatusStory]()
    var arrSelectedIndexes = [Int]()
    
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: NC_ViewerRefresh), object: nil)
        
        layoutUI()
        reloadTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func layoutUI(){
        tblView.delegate = self
        tblView.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
    }
    @objc func reloadTable(){
        arrMyStories = CoreDBManager.sharedDatabase.getStories(ForFriends: false)
        arrMyStories = arrMyStories.sorted(by: { (story1, story2) -> Bool in
            return Int(story1.storyID)! < Int(story2.storyID)!
        })
        tblView.reloadData()
    }
    
    //MARK:- BUTTON CLICKS
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        endTableViewEditing()
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        startTableViewEditing()
    }
    @IBAction func btnviewclicked(_ sender: UIButton) {
        if tblView.isEditing == false
        {
            let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryNavigatorVC) as! StoryNavigatorVC
            vc.transitioningDelegate = self
            vc.interactor = interactor
            vc.redirectFrom = "MyStory"
            vc.selectedRow = sender.tag
            let model = StoryListModel.init(
                userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                userName: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                profileURL: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile),
                arrStories: arrMyStories)
            vc.arrStory = [model]
            vc.isviewtapped = true
            vc.isMyStory = true
            APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        
        if arrSelectedIndexes.count > 0{
            
            showHUD()
            hudText = ""
            var arrStoryIDsForDeletion = [String]()
            for selectedIndex in arrSelectedIndexes{ arrStoryIDsForDeletion.append(arrMyStories[selectedIndex].storyID) }
            
            let dic = [ "status_ids" : arrStoryIDsForDeletion.joined(separator: ",") ] as [String : Any]
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyDeleteStory,dic).timingOut(after: 30) {data in
                let data = data as Array
                if(data.count > 0) {
                    hideHUD()
                    postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                    
                    self.endTableViewEditing()
                    
                    CoreDBManager.sharedDatabase.deleteStories(byStoryIDs: arrStoryIDsForDeletion)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        APP_DELEGATE.appNavigation?.popViewController(animated: true)
                    })
                    
                    //Notify implement changes in my Status to other 
                    APP_DELEGATE.socketIOHandler?.socket?.emit("StatusPrivacyNotify", with: [dic])
                }
            }
        }else{
            showMessage("Select a Story to be deleted.")
        }
    }
    
    @IBAction func btnnewstoryclicked(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idCreateStoryVC) as! CreateStoryVC
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    //MARK:- TABLEVIEW EDITING
    func startTableViewEditing(){
        tblView.setEditing(true, animated: true)
        btnEdit.isHidden = true
        btnBack.isHidden = true
        btnDelete.isHidden = false
        btnCancel.isHidden = false
    }
    
    func endTableViewEditing(){
        tblView.setEditing(false, animated: true)
        btnEdit.isHidden = false
        btnBack.isHidden = false
        btnDelete.isHidden = true
        btnCancel.isHidden = true
        arrSelectedIndexes = [Int]()
    }
    
}

extension MyStoriesVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrMyStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyStoryDetailCell") as! MyStoryListCell
        let myStory = arrMyStories[indexPath.row]
        if myStory.storyType == "0"
        {
            let nm = myStory.mediaURL.toUrl?.lastPathComponent
            let strnm = nm?.components(separatedBy: ".")
            let imgnmurl = "\(Get_Status_URL + "/" + strnm![0])_thumb.jpg"
            
            cell.imgpic.sd_setImage(with: imgnmurl.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
        }
        else
        {
            cell.imgpic.sd_setImage(with: myStory.mediaURL.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
        }
        cell.btntotalview.tag = indexPath.row
        let strDate = myStory.createdDate
        let storyDate:NSDate = DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strDate)
        let currentDate:NSDate =  NSDate()
        if storyDate as Date == currentDate as Date
        {
            cell.lbldate.text = "Just Now"
        }
        else if storyDate as Date > currentDate as Date
        {
            cell.lbldate.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: true)
        }
        else
        {
            cell.lbldate.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: false)
        }
        cell.btntotalview.setTitle("\(CoreDBManager.sharedDatabase.getViewers(ForMyStoryID: myStory.storyID).count)", for: .normal)
        cell.tintColor = themeWakeUppColor
        cell.selectionStyle = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tblView.isEditing == false
        {
            /*let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryVC) as! StoryVC
             vc.ismystory = true
             //vc.arrstory = self.arrMyStories
             vc.transitioningDelegate = self
             vc.interactor = interactor
             vc.selectedrow = indexPath.row
             APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: {
             })*/
            let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryNavigatorVC) as! StoryNavigatorVC
            vc.transitioningDelegate = self
            vc.interactor = interactor
            vc.redirectFrom = "MyStory"
            vc.selectedRow = indexPath.row
            
            var imgName = UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
            imgName = (imgName.url?.lastPathComponent)!
            let model = StoryListModel.init(
                userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                userName: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                profileURL: imgName,
                arrStories: arrMyStories)
            vc.arrStory = [model]
            vc.isMyStory = true
            vc.isviewtapped = false
            APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
        }
        else
        {
            if arrSelectedIndexes.contains(indexPath.row){
                arrSelectedIndexes.remove(at: arrSelectedIndexes.index(of: indexPath.row)!)
            }else{
                arrSelectedIndexes.append(indexPath.row)
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
        }
    }
    
}

extension MyStoriesVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
}

