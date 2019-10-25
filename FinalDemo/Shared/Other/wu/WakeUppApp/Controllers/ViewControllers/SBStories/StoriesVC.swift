 //
//  StoriesVC.swift
//  WakeUppApp
//
//  Created by Admin on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
 

class StoriesVC: UIViewController {
    //MARK:- Outlet
    @IBOutlet var tbllist: UITableView!
    @IBOutlet var vwnavbar: UIView!
    @IBOutlet var btnnewstory: UIButton!
    
    @IBOutlet weak var btngear: UIButton!
    @IBOutlet weak var chatDot: UIImageView!
    
    @IBOutlet var heightsearchstory: NSLayoutConstraint!
    @IBOutlet var searchstory: UISearchBar!
    
    //MARK:- Variable
    var arrMyStories = [ StoryListModel ]()
    var arrRecentStories = [ StoryListModel ] ()
    var arrViewedStories = [ StoryListModel ] ()
    
    var filterStories = [ StoryListModel ] ()
    var mergeArray = [ StoryListModel ] ()
    var searchclicked = false
    
    let interactor = Interactor()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(loadStoriesFromServer), name: NSNotification.Name(rawValue: NC_FriendStoryRefresh), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setChatDot), name: NSNotification.Name(NC_ChatDotChanged), object: nil)
        setChatDot()
        
        self.heightsearchstory.constant = 0
        searchstory.text = ""
        searchstory.delegate = self
        searchstory.backgroundImage = UIImage()
        
        layoutUI()
    }
    
    @objc func setChatDot(){
        chatDot.isHidden = !APP_DELEGATE.chatDotVisible
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadTable()
        loadStoriesFromServer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        APP_DELEGATE.storyDotVisible = false
    }
    
    func layoutUI(){
        tbllist.dataSource = self
        tbllist.delegate = self
        CoreDBManager.sharedDatabase.deleteExpiredStory { (done) in
        }
    }
    
    func reloadTable()
    {
        arrMyStories.removeAll()
        var arrMyStory = CoreDBManager.sharedDatabase.getStories(ForFriends: false)
        arrMyStory = arrMyStory.sorted { (story1, story2) -> Bool in
            return Int(story1.storyID)! < Int(story2.storyID)!
        }
        let model = StoryListModel.init(
            userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            userName: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            profileURL: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile),
            arrStories: arrMyStory)
        arrMyStories.append(model)
        
        arrRecentStories.removeAll()
        arrViewedStories.removeAll()
        
        let arrFriendStories = CoreDBManager.sharedDatabase.getStories(ForFriends: true)
        
        let arrGroupedFriendStories = arrFriendStories.group(by: {$0.userID})
        
        for groupedStory in arrGroupedFriendStories{
            
            let grpdStory = [groupedStory.key : groupedStory.value]
            let isAllViewedByMe = groupedStory.value.map({$0.isViewedByMe})
            
            if isAllViewedByMe.contains("0")
            {
                //THIS groupedStory SHOULD BE IN RECENT STORIES
                var firstStory = grpdStory.values.first!.first!
                var nameval = firstStory.userName
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: firstStory.countrycode, phoneNo: firstStory.phoneno)
                if objContactInfo.Name?.count == 0 {
                    //print("NOT IN CONTACTS")
                }
                else
                {
                    nameval = objContactInfo.Name!
                    firstStory.userName = nameval
                    var model = StoryListModel.init(
                        userID: firstStory.userID,
                        userName: nameval,
                        profileURL: firstStory.profileURL,
                        arrStories: grpdStory.values.first!)
                    
                    let array = model.arrStories
                    model.arrStories = array.sorted(by: { (story1, story2) -> Bool in
                        return Int(story1.storyID)! < Int(story2.storyID)!
                    })
                    arrRecentStories.append(model)
                }
            }else{
                //THIS groupedStory SHOULD BE IN VIEWED STORIES
                let firstStory = grpdStory.values.first!.first!
                var nameval = firstStory.userName
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: firstStory.countrycode, phoneNo: firstStory.phoneno)
                if objContactInfo.Name?.count == 0 {
                    //print("NOT IN CONTACTS")
                }
                else
                {
                    nameval = objContactInfo.Name!
                    var model = StoryListModel.init(
                        userID: firstStory.userID,
                        userName: nameval,
                        profileURL: firstStory.profileURL,
                        arrStories: grpdStory.values.first!)
                    
                    let array = model.arrStories
                    model.arrStories = array.sorted(by: { (story1, story2) -> Bool in
                        return Int(story1.storyID)! < Int(story2.storyID)!
                    })
                    arrViewedStories.append(model)
                }
            }
        }
        
        arrRecentStories = arrRecentStories.sorted { (storyList1, storyList2) -> Bool in
            return Int(storyList1.arrStories.last!.storyID)! > Int(storyList2.arrStories.last!.storyID)!
        }
        
        arrViewedStories = arrViewedStories.sorted { (storyList1, storyList2) -> Bool in
            return Int(storyList1.arrStories.last!.storyID)! > Int(storyList2.arrStories.last!.storyID)!
        }
        
        mergeArray = arrRecentStories + arrViewedStories
        tbllist.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnsettingclicked(_ sender: Any) {
        let objVC : PrivacyVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPrivacyVC) as! PrivacyVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    //MARK:- BUTTON CLICKS ACTION
    @IBAction func btnchatclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
        
    }
    @IBAction func btnstoryclicked(_ sender: Any) {
        /*let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: "storylistvc") as! StoryListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC)
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    @IBAction func btnpostclicked(_ sender: Any) {
        /* let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "feedlistvc") as! FeedListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let feeds = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(feeds, animated: false)
    }
    
    /*@IBAction func btnnotifclicked(_ sender: Any) {
     let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "NotificationVC") as! NotificationVC
     APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
     }*/
    
    @IBAction func btnchannelclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelListVC) as! ChannelListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnuserclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: "ProfileVC") as! ProfileVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnNewStoryClicked(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idCreateStoryVC) as! CreateStoryVC
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnsearchclicked(_ sender: Any)
    {
        searchstory.text = ""
        if searchclicked == true
        {
            self.heightsearchstory.constant = 0
            self.searchstory.resignFirstResponder()
            searchclicked = false
        }
        else
        {
            searchclicked = true
            self.heightsearchstory.constant = 56
            self.searchstory.becomeFirstResponder()
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension StoriesVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if checkSearchBarActive(searchbar: self.searchstory)
        {
            return 1
        }
        else
        {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if checkSearchBarActive(searchbar: self.searchstory)
        {
            return filterStories.count
        }
        else
        {
            if section == 0
            {
                return 1
            }
            else if section == 1
            {
                return arrRecentStories.count
            }
            else
            {
                return arrViewedStories.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryListCell")
        let lblname = cell?.viewWithTag(12) as! UILabel
        let lbltime = cell?.viewWithTag(13) as! UILabel
        let imgpro = cell?.viewWithTag(11) as! UIImageView
        let imgborder = cell?.viewWithTag(10) as! UIImageView
        let btncount = cell?.viewWithTag(21) as! UIButton
        
        imgpro.image = nil
        
        if indexPath.section == 0
        {
            if checkSearchBarActive(searchbar: self.searchstory)
            {
                let groupedStory = filterStories[indexPath.row]
                
                let storiesOfThisFriend = groupedStory.arrStories
                
                let lastStoryInGroup = storiesOfThisFriend.last!
                
                lblname.text = "You";// lastStoryInGroup.userName
                
                imgpro.image = nil
                
                if lastStoryInGroup.storyType == "0"
                {
                    let nm = lastStoryInGroup.mediaURL.toUrl?.lastPathComponent
                    let strnm = nm?.components(separatedBy: ".")
                    let imgnmurl = "\(Get_Status_URL + "/" + strnm![0])_thumb.jpg"
                    
                    imgpro.sd_setImage(with: imgnmurl.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
                }
                else
                {
                    imgpro.sd_setImage(with: lastStoryInGroup.mediaURL.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
                }
                
                lbltime.text = timeAgoSinceStrDate(strDate: lastStoryInGroup.createdDate, numericDates: true).capitalized
                
                imgborder.rotateWithLimit()
                imgborder.image = UIImage.init(named: "story_border")
                imgborder.layer.borderWidth = 0
                imgborder.layer.borderColor = UIColor.clear.cgColor
                
                btncount.setTitle("\(storiesOfThisFriend.count)", for: .normal)
            }
            else
            {
                if arrMyStories.first!.arrStories.count == 0
                {
                    lblname.text = "You" // UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)//"My Story"
                    lbltime.text = "Tap to add story".localized()
                    //PV
                    /*imgpro.sd_setImage(with: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile).toUrl,  placeholderImage: StoryPlaceHolder, options: .delayPlaceholder, completed: { (img, err, type, url) in
                    })*/
                    //imgpro.image = #imageLiteral(resourceName: "new_story")
                    imgpro.image = #imageLiteral(resourceName: "my_story_add")
                    
                    btncount.setTitle("0", for: .normal)
                }
                else
                {
                    let obj = arrMyStories.first!.arrStories.last!
                    lblname.text = "You" //UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
                    imgborder.image = UIImage.init(named: "story_border")
                    imgborder.layer.borderColor = UIColor.clear.cgColor
                    
                    lbltime.text = timeAgoSinceStrDate(strDate: obj.createdDate, numericDates: true).capitalized
                    if obj.storyType == "0"
                    {
                        let nm = obj.mediaURL.toUrl?.lastPathComponent
                        let strnm = nm?.components(separatedBy: ".")
                        let imgnmurl = "\(Get_Status_URL + "/" + strnm![0])_thumb.jpg"
                        
                        imgpro.sd_setImage(with: imgnmurl.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
                    }
                    else
                    {
                        imgpro.sd_setImage(with: obj.mediaURL.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
                    }
                    btncount.setTitle("\(arrMyStories.first!.arrStories.count)", for: .normal)
                }
            }
        }
        else  if indexPath.section == 1
        {
            let groupedStory = arrRecentStories[indexPath.row]
            let storiesOfThisFriend = groupedStory.arrStories
            let lastStoryInGroup = storiesOfThisFriend.last!
            lblname.text = lastStoryInGroup.userName
            imgpro.image = nil
            if lastStoryInGroup.storyType == "0"
            {
                let nm = lastStoryInGroup.mediaURL.toUrl?.lastPathComponent
                if let value = nm { //PV
                //let strnm = nm?.components(separatedBy: ".")
                let strnm = value.components(separatedBy: ".")
                let imgnmurl = "\(Get_Status_URL + "/" + strnm[0])_thumb.jpg"
                imgpro.sd_setImage(with: imgnmurl.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
                }
                else { imgpro.image = #imageLiteral(resourceName: "channel_placeholder") }
            }
            else
            {
                imgpro.sd_setImage(with: lastStoryInGroup.mediaURL.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
            }
            //lbltime.text = timeAgoSinceStrDate(strDate: lastStoryInGroup.createdDate, numericDates: true).capitalized
            let storyDate:NSDate = DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: lastStoryInGroup.createdDate)
            let currentDate:NSDate =  NSDate()
            if storyDate as Date == currentDate as Date
            {
                //lbltime.text = "Just Now"
                lbltime.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: false)
            }
            else if storyDate as Date > currentDate as Date
            {
                lbltime.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: true)
            }
            else
            {
                lbltime.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: false)
            }
            imgborder.rotateWithLimit()
            imgborder.image = UIImage.init(named: "story_border")
            imgborder.layer.borderWidth = 0
            imgborder.layer.borderColor = UIColor.clear.cgColor
            
            btncount.setTitle("\(storiesOfThisFriend.count)", for: .normal)
        }
        else
        {
            let groupedStory = arrViewedStories[indexPath.row]
            
            let storiesOfThisFriend = groupedStory.arrStories
            
            let lastStoryInGroup = storiesOfThisFriend.last!
            
            lblname.text = lastStoryInGroup.userName
            if lastStoryInGroup.storyType == "0"
            {
                let nm = lastStoryInGroup.mediaURL.toUrl?.lastPathComponent
                let strnm = nm?.components(separatedBy: ".")
                let imgnmurl = "\(Get_Status_URL + "/" + strnm![0])_thumb.jpg"
                
                imgpro.sd_setImage(with: imgnmurl.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
            }
            else
            {
                imgpro.sd_setImage(with: lastStoryInGroup.mediaURL.toUrl, placeholderImage: UserPlaceholder, options: .delayPlaceholder, completed: { (img, err, type, url) in })
            }
            
            lbltime.text = timeAgoSinceStrDate(strDate: lastStoryInGroup.createdDate, numericDates: true).capitalized
            
            imgborder.image = UIImage.init(named: "")
            imgborder.layer.removeAllAnimations()
            imgborder.layer.borderColor = UIColor.lightGray.cgColor
            imgborder.layer.borderWidth = 2
            
            btncount.setTitle("\(storiesOfThisFriend.count)", for: .normal)
        }
        
        btncount.isHidden = false
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        /*if indexPath.section == 0
         {
         if arrMyStories.count == 0 {
         let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idCreateStoryVC) as! CreateStoryVC
         APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
         }
         else{
         let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idMyStoriesVC)
         APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
         }
         }
         else  if indexPath.section == 1 {
         let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryVC) as! StoryVC
         //vc.arrstory = self.arrRecentStories
         vc.ismystory = false
         vc.transitioningDelegate = self
         vc.interactor = interactor
         vc.selectedrow = indexPath.row
         vc.redirectfrom = "FriendStory"
         APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
         }
         else {
         let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryVC) as! StoryVC
         //vc.arrstory = self.arrViewedStories
         vc.ismystory = false
         vc.transitioningDelegate = self
         vc.interactor = interactor
         vc.selectedrow = indexPath.row
         vc.redirectfrom = "FriendStory"
         APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
         }*/
        
        switch indexPath.section {
        case 0:
            if checkSearchBarActive(searchbar: self.searchstory)
            {
                let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryNavigatorVC) as! StoryNavigatorVC
                vc.transitioningDelegate = self
                vc.interactor = interactor
                vc.redirectFrom = "FriendStory"
                vc.selectedRow = indexPath.row
                vc.arrStory = filterStories
                APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
            }
            else
            {
                if arrMyStories.first!.arrStories.count == 0 {
                    let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idCreateStoryVC) as! CreateStoryVC
                    APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                }
                else{
                    let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idMyStoriesVC)
                    APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                }
            }
        case 1,2:
            let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryNavigatorVC) as! StoryNavigatorVC
            vc.transitioningDelegate = self
            vc.interactor = interactor
            vc.redirectFrom = "FriendStory"
            vc.selectedRow = indexPath.row
            if indexPath.section == 1{
                vc.arrStory = arrRecentStories
            }else{
                vc.arrStory = arrViewedStories
            }
            
            APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
        default:
            break
        }
        
        //APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35))
        label.font = FontWithSize(FT_Medium, 14)
        switch section{
        case 0:
            label.text="     MY STORY"
        case 1:
            label.text="     RECENT STORIES"
        case 2:
            label.text="     VIEWED STORIES"
        default:
            print()
        }
        label.textColor = UIColor.darkGray
        label.backgroundColor = self.tbllist.backgroundColor
        view.addSubview(label)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(section == 0)
        {
            return 35
        }
        else if (section == 1)
        {
            if (self.arrRecentStories.count == 0)
            {
                return 0
            }
            else
            {
                return 35
            }
        }
        else
        {
            if (self.arrViewedStories.count == 0)
            {
                return 0
            }
            else
            {
                return 35
            }
        }
    }
}

extension StoriesVC {
    
    @objc func loadStoriesFromServer(){
        reloadTable()
        getMyStatusFromServer()
        getFriendStatusFromServer()
    }
    
    func getMyStatusFromServer(){
        let msgDictionary = ["user_id":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Get_AllMyStatusStory",msgDictionary).timingOut(after: 60)
        {data in
            print(data)
            //var arrStory = [StructStoryData]()
            //var viewarrStory = [StructStoryData]()
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String{
                    return
                }
                let dic = data[0] as! NSDictionary
                if dic.value(forKey: "success") as! String == "1"
                {
                    let arrStories = dic.value(forKey: "status")  as! Array<[String:Any]>
                    for dicData in arrStories {
                        
                        let mediaName =  dicData["image"] as? String ?? ""
                        
                        let myStory = StructStatusStory.init(
                            storyID: "\(dicData["status_id"] ?? "")",
                            createdDate: dicData["creation_datetime"] as? String ?? "",
                            storyType: mediaName.contains("jpg") || mediaName.contains("png") ?  "1" : "0",
                            mediaURL: "\(Get_Status_URL)/\(mediaName)",
                            isViewedByMe: "1",
                            userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            duration: "\(dicData["storyduration"] ?? "5")",
                            profileURL: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile),
                            userName: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                            allowCopy: "\(dicData["allowcopy"] ?? "0")",
                            caption:  dicData["storycaption"] as? String ?? "",
                            statusprivacy: "\(dicData["status_privacy"] ?? "2")",
                            countrycode:"\(dicData["country_code"] ?? "91")",
                            phoneno:"\(dicData["phoneno"] ?? "0")",
                            statusviewprivacy: "\(dicData["statusviewprivacy"] ?? "1")",
                            markedusers: "\(dicData["markedusers"] ?? "0")"
                        )
                        CoreDBManager.sharedDatabase.saveStoriesInLocalDB(stories: [myStory])
                    }
                    
                    let arrViewers = dic.value(forKey: "view_detail") as! Array<[String:Any]>
                    for dicData in arrViewers{
                        let viewer = StructStoryViewers.init(
                            storyID: "\(dicData["status_id"] ?? "")",
                            userID: "\(dicData["viewer_id"] ?? "")",
                            createdDate: "\(dicData["creation_datetime"] ?? "")",
                            profileURL: "\(dicData["userprofile"] ?? "")",
                            userName: "\(dicData["username"] ?? "")",
                            countrycode:"\(dicData["country_code"] ?? "91")",
                            phoneno: "\(dicData["phoneno"] ?? "2")")
                        CoreDBManager.sharedDatabase.saveViewersInLocalDB(ForStoryID: viewer.storyID, viewers: [viewer])
                    }
                    self.reloadTable()
                }
            }
        }
    }
    
    func getFriendStatusFromServer(){
        
        let appUsers = UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUsers) as! [User]
        let appuserids = appUsers.map({$0.userId!}).joined(separator: ",")
        
        let msgDictionary = ["user_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), "appuserids" : appuserids] as [String:Any]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Get_FriendsStory",msgDictionary).timingOut(after: 60)
        {data in
            print(data)
            //var arrStory = [StructStoryData]()
            //var viewarrStory = [StructStoryData]()
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String{
                    //StoryLoadComplete([],[])
                    return
                }
                let dic = data[0] as! NSDictionary
                
                if dic.value(forKey: "success") as! String == "1"
                {
                    let arrStories = dic.value(forKey: "status")  as! Array<[String:Any]>
                    for dicData in arrStories
                    {
                        let mediaName =  dicData["image"] as? String ?? ""
                        var friendStory = StructStatusStory.init(
                            storyID: "\(dicData["status_id"] ?? "")",
                            createdDate: dicData["creation_datetime"] as? String ?? "",
                            storyType: mediaName.contains("jpg") || mediaName.contains("png") ?  "1" : "0",
                            mediaURL: "\(Get_Status_URL)/\(mediaName)",
                            isViewedByMe: "0",
                            userID: "\(dicData["storyownerid"] ?? "")",
                            duration: "\(dicData["storyduration"] ?? "5")",
                            profileURL: "\(dicData["userprofile"] as? String ?? "")",
                            userName: dicData["username"] as? String ?? "",
                            allowCopy: "\(dicData["allowcopy"] ?? "0")",
                            caption:  dicData["storycaption"] as? String ?? "",
                            statusprivacy: "\(dicData["status_privacy"] ?? "2")",
                            countrycode:"\(dicData["country_code"] ?? "91")",
                            phoneno:"\(dicData["phoneno"] ?? "0")",
                             statusviewprivacy: "\(dicData["statusviewprivacy"] ?? "1")",
                            markedusers: "\(dicData["markedusers"] ?? "0")"
                        )
                        var nameval = friendStory.userName
                        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: friendStory.countrycode, phoneNo: friendStory.phoneno)
                        if objContactInfo.Name?.count == 0
                        {
                            nameval = "+\(friendStory.countrycode) \(friendStory.phoneno)"
                        }
                        else
                        {
                            nameval = objContactInfo.Name!
                            friendStory.userName = nameval
                            CoreDBManager.sharedDatabase.saveStoriesInLocalDB(stories: [friendStory])
                        }
                    }
                    let arrViewers = dic.value(forKey: "view_detail") as! Array<[String:Any]>
                    for dicData in arrViewers{
                        let viewer = StructStoryViewers.init(
                            storyID: "\(dicData["status_id"] ?? "")",
                            userID: "\(dicData["viewer_id"] ?? "")",
                            createdDate: "\(dicData["creation_datetime"] ?? "")",
                            profileURL: "\(dicData["userprofile"] ?? "")",
                            userName: "\(dicData["username"] ?? "")",
                            countrycode:"\(dicData["country_code"] ?? "91")",
                            phoneno:"\(dicData["phoneno"] ?? "0")")
                        CoreDBManager.sharedDatabase.saveViewersInLocalDB(ForStoryID: viewer.storyID, viewers: [viewer])
                        
                        if viewer.userID == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                            CoreDBManager.sharedDatabase.setStoryIsViewedByMe(ForStoryID: viewer.storyID)
                        }
                        
                    }
                    
                    self.reloadTable()
                }
            }
        }
        
    }
    
}

extension StoriesVC: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension StoriesVC: UISearchBarDelegate
{
    func filterStoryUser(_ searchText: String)
    {
        filterStories = mergeArray.filter({(StoryListModel ) -> Bool in
            let value = StoryListModel.userName.lowercased().contains(searchText.lowercased())
            print(value)
            print(StoryListModel.userName)
            return value
        })
        
        tbllist.reloadData()
        //        if let foo = mergeArray.first(where: {$0.name == "foo"}) {
        //            // do something with foo
        //        } else {
        //            // item could not be found
        //        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.filterStoryUser(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchstory.text = ""
        self.heightsearchstory.constant = 0
        searchclicked = false
        self.tbllist.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

