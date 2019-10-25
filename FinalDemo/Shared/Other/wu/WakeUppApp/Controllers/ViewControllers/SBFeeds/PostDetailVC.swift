//
//  PostDetailVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 18/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {

    @IBOutlet var btnback: UIButton!
    @IBOutlet var lbltitle: UILabel!
    @IBOutlet var tbldetails: UITableView!
    var selectedpost:PostData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
        // Do any additional setup after loading the view.
    }
    @IBAction func btnbackclicked(_ sender: Any) {
        _ = APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func layoutUI() {
        self.tbldetails.delegate = self
        self.tbldetails.dataSource = self
        self.tbldetails.reloadData()
        self.tbldetails.rowHeight = UITableViewAutomaticDimension
        self.tbldetails.estimatedRowHeight = 375
    }

}
extension PostDetailVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListCell") as! FeedListCell
        
        cell.viewMain.backgroundColor = UIColor.white
        cell.viewMain.cornerRadius = 10
        
        cell.imgProfile.sd_setImage(with: URL.init(string: selectedpost.image!), placeholderImage: ProfilePlaceholderImage)
        cell.lblName.text = selectedpost.username
        cell.lblLocation.text = selectedpost.location
        cell.pageControl.numberOfPages = (selectedpost.postImages?.count)!
        cell.pageControl.currentPage = 0
        let attrString = selectedpost.postDescIos?.html2AttributedString
        if selectedpost.peopleTags!.count > 0
        {
            let strPeopleTag = selectedpost.peopleTags!.map({$0})
     
            let attributedNames = NSMutableAttributedString(string:"\n \(strPeopleTag)")
            attributedNames.addAttribute(NSAttributedStringKey.font, value: UIFont.init(name: FT_Regular, size: 13)!, range: NSMakeRange(0, attributedNames.length))
            attributedNames.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attributedNames.length))
            
            let combination = NSMutableAttributedString()
            
            combination.append(attrString!)
            combination.append(attributedNames)
            cell.lblCaption.attributedText = combination
        }else{
            cell.lblCaption.attributedText = attrString
        }

       
        if selectedpost.location?.count == 0{
            cell.heightBtnLocation.constant = 0
            cell.heightLblLocation.constant = 0
        }
        else {
            cell.heightBtnLocation.constant = 25
            cell.heightLblLocation.constant = 25
        }

        cell.lblCaption.numberOfLines = 0
        cell.lblCaption.layoutIfNeeded()
    
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        cell.collectionView.reloadData()
       
        var strDate = selectedpost.creationDatetime!
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strDate) as Date
        strDate = timeAgoSinceDate(date: date, numericDates: true)
        cell.lblTime.text = strDate
        cell.widthdots.constant = 0
         cell.btnShare.isHidden = true
        cell.btnLike.isHidden = true
        cell.btnNoOfLike.isHidden = true
        cell.btnMore.isHidden = true
        cell.btnComment.isHidden = true
        cell.lblNoOfLike.isHidden = true
        //                let objUserPost_PostImage : PostImages = arrUserPost_PostImage[0]
        //
        //                //Detect Post is Video and manage Play Video--->
        //                strURL = objUserPost_PostImage.postImage!
        //                let arrDetectPostType : NSArray = strURL.components(separatedBy: ".") as NSArray
        //                let strPostExtension : String = arrDetectPostType.lastObject as! String
        //
        //                if (strPostExtension.uppercased() != "jpg".uppercased()) {
        //                    cell.btnPlay.isHidden = false
        //                    cell.btnPlay.tag = indexPath.row
        //                    cell.btnPlay.addTarget(self, action: #selector(Manage_PostVideo_Play(sender:)), for: .touchUpInside)
        //
        //                    //Set Default Image
        //                    cell.imgPic.image = SquarePlaceHolderImage
        //                }
        //                else {
        //                    strURL = objUserPost_PostImage.imagePath!
        //                    cell.imgPic.sd_setImage(with: URL.init(string: strURL), placeholderImage: SquarePlaceHolderImage)
        //                }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
extension PostDetailVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let post = selectedpost.postImages![indexPath.row]
        let path = post.imagePath!
//        pageControl.currentPage = currentPage
        if isPathForVideo(path: path){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedVideoCell", for: indexPath) as! FeedVideoCell
            cell.post = post
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
            cell.post = post
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedpost.postImages!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize.init(width:  SCREENWIDTH() - 11, height: collectionView.frame.height)
        return collectionView.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
         let cell = self.tbldetails.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! FeedListCell
        if scrollView == cell.collectionView {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = Int(ceil(x/w))
            cell.pageControl.currentPage = currentPage
        }
    }
    
}
