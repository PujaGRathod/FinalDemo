 //
 //  PostVC.swift
 //  WakeUppApp
 //
 //  Created by Admin on 29/03/18.
 //  Copyright © 2018 el. All rights reserved.
 //
 
 import UIKit
 import AVKit
 import MapKit
 import IQKeyboardManagerSwift
 //import SimpleImageViewer
 import SwiftyJSON

 class PostVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet var collpostimages: UICollectionView!
    @IBOutlet var btnpost: UIButton!
    @IBOutlet var pgcontrol: UIPageControl!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewMapPlaceholder: UIView!
    @IBOutlet weak var lblLocationError: UILabel!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet var txtdesc: IQTextView!
    @IBOutlet weak var mapCenter: NSLayoutConstraint!
    @IBOutlet weak var tblLocation: UITableView!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet var btntagpeople: UIButton!
    
    @IBOutlet var btndone: UIButton!
    var arrLocation = [String]()
    //var arrPeople = [String]()
    var arrSelectedPath = [IndexPath]()
    var isLocationTable = true
    var mediaForUpload = NSArray()
    var player = AVPlayer.init()
    var playerLayer = AVPlayerLayer.init()
    var uploadediimages = ""
    
    var arrAssets = [FilterAssetModel]()
    
    var arrFollowing = [FollowList_Following]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        isStatusBarHidden = false
        tblLocation.dataSource = self
        tblLocation.delegate = self
        viewLocation.alpha = 0.0
        //mapCenter.constant = SCREENHEIGHT()/2 + 200
        tblLocation.tableFooterView = UIView()
        
        self.collpostimages.delegate = self
        self.collpostimages.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.pgcontrol.numberOfPages = arrAssets.count
        
        api_FollowList(userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    @objc func playerDidFinishPlaying(note: NSNotification){
        //print("Video Finished")
        player.seek(to: kCMTimeZero)
        player.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnbackclicked(_ sender: Any)
    {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func txtDescriptionClicked(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idPostCaptionVC) as! PostCaptionVC
        vc.delegate = self
        vc.prefilledCaption = txtdesc.text
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnpostclicked(_ sender: Any) {
        self.api_UploadFeeds()
    }
    @IBAction func btndoneclicked(_ sender: Any)
    {
        var listofname = ""
        /*for index in arrSelectedPath
        {
            let ipath = index
            
            let nm = arrPeople[ipath.row]
            if (arrSelectedPath.last) != index
            {
                listofname = listofname + ("\(nm)," )
            } else {
                listofname = listofname + (nm)
            }
        }
        
        if arrSelectedPath.count > 1
        {
            let fname = arrPeople[arrSelectedPath[0].row]
            let str = "\(fname) & \(arrSelectedPath.count - 1) more"
            self.btntagpeople.setTitle( str , for: .normal)
        }
        else
        {
            self.btntagpeople.setTitle(listofname.count > 0 ? listofname : "Tag People", for: .normal)
        }*/
        if arrSelectedPath.count == 0{
            self.btntagpeople.setTitle("Tag People", for: .normal)
        }else{
            let firstIndexPath = arrSelectedPath[0]
            let firstPerson = arrFollowing[firstIndexPath.row]
            var taggedNames = firstPerson.fullName!
            if arrSelectedPath.count > 1{
                taggedNames = "\(taggedNames) and \(arrSelectedPath.count-1) others"
            }
            self.btntagpeople.setTitle(taggedNames, for: .normal)
        }
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLocation.alpha = 0.0
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            //self.mapCenter.constant = SCREENHEIGHT()/2 + 200
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func btnAddLocation(_ sender: Any) {
        self.btndone.isHidden = true
        isLocationTable = true
        tblLocation.reloadData()
        self.txtLocation.text = ""
        lblLocationError.text = "Please enter your location... ".localized()
        self.txtLocation.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLocation.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            //self.mapCenter.constant = 0
            self.view.layoutIfNeeded()
        }) { (isComplete) in
            self.txtLocation.becomeFirstResponder()
        }
        
    }
    
    @IBAction func btnTagPeopleClicked(_ sender: Any) {
        self.btndone.isHidden = false
        isLocationTable = false
        
        self.tblLocation.reloadData()
        viewMapPlaceholder.isHidden = true
        self.txtLocation.isUserInteractionEnabled = false
        self.txtLocation.text = "Select People".localized()
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLocation.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            //self.mapCenter.constant = 0
            self.view.layoutIfNeeded()
        }) { (isComplete) in
        }
    }
    @IBAction func btnCloseMapView(_ sender: Any) {
        
        self.view.endEditing(true)
        self.txtLocation.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLocation.alpha = 0.0
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            //self.mapCenter.constant = SCREENHEIGHT()/2 + 200
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func searchLocation(_ sender: UITextField) {
        
        let strLocation:String = "\(sender.text ?? "")"
        if(strLocation.count > 0)
        {
            self.getAddressList("\(sender.text ?? "")")
        }
        else
        {
            lblLocationError.text = "Please enter your location..."
            viewMapPlaceholder.isHidden = false
            tblLocation.isHidden = true
        }
        
    }
    func getLocationFromAddress()
    {
        if self.txtLocation.text!.count > 0{
            let geocoder = CLGeocoder()
            var coordinates = CLLocationCoordinate2D()
            geocoder.geocodeAddressString(self.txtLocation.text!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    //print("Error", error!)
                }
                if let placemark = placemarks?.first
                {
                    coordinates = placemark.location!.coordinate
                    self.api_postFeed("\(coordinates.latitude)","\(coordinates.longitude)")
                }
            })
        }else{
            self.api_postFeed("","")
        }
    }
    func getAddressList(_ strAddress:String)
    {
        let escapedAddress = strAddress.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let fileUrl = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(escapedAddress!)&language=en&key=\(GoogleAPI)")
        let data = try? Data(contentsOf: fileUrl!)
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if(json["status"] as? String == "OK")
            {
                arrLocation.removeAll()
                if let result:NSArray = json["predictions"] as? NSArray {
                    for i in 0..<result.count
                    {
                        let dicData =  result[i] as! NSDictionary
                        arrLocation.append(dicData.value(forKey: "description") as! String)
                    }
                    
                    if(arrLocation.count > 0)
                    {
                        viewMapPlaceholder.isHidden = true
                        tblLocation.isHidden = false
                        tblLocation.reloadData()
                    }
                    else
                    {
                        lblLocationError.text = "Couldn't find any location... "
                        viewMapPlaceholder.isHidden = false
                        tblLocation.isHidden = true
                    }
                    
                }
            }
        } catch {}
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isLocationTable == true
        {
            return arrLocation.count
        }
        else
        {
            return arrFollowing.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tblLocation.dequeueReusableCell(withIdentifier: "locationCell")!
        let lblLocation = cell.viewWithTag(100) as! UILabel
        let imgcell = cell.viewWithTag(110) as! UIImageView
        let btn = cell.viewWithTag(111) as! UIButton
        btn.isUserInteractionEnabled = false
        if isLocationTable == true
        {
            lblLocation.text = arrLocation[indexPath.row]
            imgcell.image = UIImage.init(named: "add_location_post")
            btn.isHidden = true
        }
        else
        {
            let obj = arrFollowing[indexPath.row]
            lblLocation.text = obj.fullName
            imgcell.image = UIImage.init(named: "tag_people_post")
            btn.isHidden = false
            if(arrSelectedPath.contains(indexPath))
            {
                btn.setImage(UIImage.init(named: "check_mark_msg"), for: .normal)
            }
            else
            {
                btn.setImage(UIImage.init(named: "noimage"), for: .normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if isLocationTable == true {
            btnLocation.setTitle(arrLocation[indexPath.row], for: .normal)
            self.view.endEditing(true)
            UIView.animate(withDuration: 0.3, animations: {
                self.viewLocation.alpha = 0.0
            })
            
            UIView.animate(withDuration: 0.3, animations: {
                //self.mapCenter.constant = SCREENHEIGHT()/2 + 200
                self.view.layoutIfNeeded()
            })
        }
        else{
            if(arrSelectedPath.contains(indexPath)) {
                let idx = arrSelectedPath.index(of: indexPath)
                arrSelectedPath.remove(at: idx!)
            }
            else {
                arrSelectedPath.append(indexPath)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
 }
 
 extension PostVC : PostCaptionVCDelegate{
    func didProvideCaption(caption: String) {
        txtdesc.text = caption
        dismiss(animated: true, completion: nil)
    }
 }
 
 extension PostVC
 {
    
    func api_FollowList(userID: String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIFollowList,
                                      "request":["user_id":userID],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIFollowList, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_FollowList(userID: userID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    /*if responseArray!.count > 0 {
                     self.arrFollowing = responseArray as! [GetUserFollowing]
                     }*/
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        let arrData = dicRespo.object(forKey: "following") as! NSArray
                        let arrObjData : NSMutableArray = NSMutableArray.init()
                        for objData in arrData {
                            let j = JSON(objData)
                            let objData:FollowList_Following = FollowList_Following.init(json: j)
                            arrObjData.add(objData)
                        }
                        self.arrFollowing = arrObjData as! [FollowList_Following]
                        self.tblLocation.isHidden = false
                        self.tblLocation.reloadData()
                    }
                }
            }
        })
    }
    
    func api_UploadFeeds()
    {
        showLoaderHUD(strMessage: "Uploading Feeds")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        let arrimgs = NSMutableArray()
        for model in arrAssets{
            if model.originalPHAsset.mediaType == .image{
                let imageData:Data = UIImageJPEGRepresentation(model.croppedImage, 1.0)!
                arrimgs.add(imageData)
            }else{
                arrimgs.add(model.exportedFileURL!)
            }
        }
        
        parameter.setObject(arrimgs, forKey: ("image[]" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: uploadMedia, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            if error != nil
            {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadFeeds()
                })
                return
            }
            else if let data = data
            {
                let thedata = data as? NSDictionary
                if(thedata != nil)
                {
                    print(thedata!)
                    if (thedata?.count)! > 0
                    {
                        let images  = thedata!.object(forKey: kData) as! String
                        self.uploadediimages = images
                        self.getLocationFromAddress()
                        print(images)
                    }
                }
                else
                {
                    
                }
                hideLoaderHUD()
            }
            else
            {
                hideLoaderHUD()
            }
        }
    }
    func api_postFeed(_ lat :String,_ lon:String)
    {
        showHUD()
        self.view.endEditing(true)
        
        var tags = ""
        let arrTags = txtdesc.text.getHashTags()
        if arrTags.count > 0{
            tags = arrTags.joined(separator: ",")
        }
        
        var peopleTags = ""
        var arrTaggedPeople = [FollowList_Following]()
        for indexPath in arrSelectedPath{
            let following = arrFollowing[indexPath.row]
            arrTaggedPeople.append(following)
        }
        
        if arrTaggedPeople.count > 0{
            let arrUserIDs = arrTaggedPeople.map({$0.userId!})
            peopleTags = arrUserIDs.joined(separator: ",")
        }
        
        let parameter:NSDictionary = ["service":APIPostFeeds,
                                      "request": ["data":
                                        [
                                            "post_desc": self.txtdesc.text!,
                                            "post_type": "image",
                                            "latitude": lat,
                                            "longitude": lon,
                                            "location": self.btnLocation.titleLabel!.text!,
                                            "map_image": "",
                                            "post_image": uploadediimages,
                                            "post_tags": arrTags,
                                            "People_tags" : peopleTags,
                                        ]],
                                      "auth" : getAuthForService()
        ]
        
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateUser, parameters: parameter, keyname: "", message: "Posting feed", showLoader: true,responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            //self.btnproceed.stopAnimation()
            self.view.isUserInteractionEnabled = true
            hideLoaderHUD()
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_postFeed(lat,lon)
                })
                return
            }
            else
            {
                hideHUD()
                if Int(apistatus) == 0
                {
                    showMessage(statusmessage)
                }
                else
                {
                    if responseArray!.count > 0
                    {
                        
                    }
                    else
                    {
                        showMessage(statusmessage)
                        /*let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "feedlistvc") as! FeedListVC
                        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
                        
                        let feeds = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
                        APP_DELEGATE.appNavigation?.pushViewController(feeds, animated: false)
                    }
                }
            }
        })
    }
 }
 extension PostVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
 {
    func playvideoAtImgLayer(urlval:String,imgvw:UIImageView)
    {
        playerLayer.removeFromSuperlayer()
        let avAsset = AVAsset.init(url: urlval.toUrl!)
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        imgvw.layer.addSublayer(playerLayer)
        playerLayer.frame = imgvw.bounds
        self.view.layoutIfNeeded()
        player.seek(to: kCMTimeZero)
        player.play()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath as IndexPath)
        let imgView = cell.viewWithTag(888) as! UIImageView
        /*let img = mediaForUpload[indexPath.item] as! UIImage
        if img.accessibilityLabel == "IMAGE"
        {
            imgView.image = img
        }
        else
        {
            imgView.image = img
            playvideoAtImgLayer(urlval: img.accessibilityLabel!, imgvw: imgView)
        }*/
        
        let filterAssetModel = arrAssets[indexPath.row]
        imgView.image = filterAssetModel.croppedImage

        let imgPlayVideo = cell.viewWithTag(777) as! UIImageView
        if filterAssetModel.originalPHAsset.mediaType == .video{
            imgPlayVideo.alpha = 1.0
            //playvideoAtImgLayer(urlval: filterAssetModel.exportedFileURL!.path, imgvw: imgView)
        }else{
            imgPlayVideo.alpha = 0.0
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let filterAssetModel = arrAssets[indexPath.row]
        if filterAssetModel.originalPHAsset.mediaType == .video{
            let player = AVPlayer(url: filterAssetModel.exportedFileURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }else{
            let cell = collectionView.cellForItem(at: indexPath)!
            let configuration = ImageViewerConfiguration { config in
                config.imageView = cell.viewWithTag(888) as? UIImageView
                //config.image = filterAssetModel.croppedImage
            }
            let imageViewerController = ImageViewerController(configuration: configuration)
            present(imageViewerController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if scrollView is UICollectionView
        {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = Int(ceil(x/w))
            self.pgcontrol.currentPage = currentPage
        }
    }
 }

