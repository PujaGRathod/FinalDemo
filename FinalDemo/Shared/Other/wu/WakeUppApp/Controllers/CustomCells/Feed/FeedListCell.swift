//
//  FeedListCell.swift
//  WakeUppApp
//
//  Created by Admin on 01/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class FeedListCell: UITableViewCell {
    
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var heightBtnLocation: NSLayoutConstraint!
    @IBOutlet var heightLblLocation: NSLayoutConstraint!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var btnMore: UIButton!
    
    
    @IBOutlet weak var viewPostData: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    
    
    @IBOutlet weak var viewPostInfo: UIView!
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var lc_btnSeeMore_Height : NSLayoutConstraint!
    @IBOutlet var btnSeeMore: UIButton!
    
    
    @IBOutlet weak var viewPostAction: UIView!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet weak var lblNoOfLike: UILabel!
    @IBOutlet weak var btnNoOfLike: UIButton!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var btnShare: UIButton!
    
    @IBOutlet var imgdots: UIImageView! 
    @IBOutlet var widthdots: NSLayoutConstraint! 
    
    @IBOutlet var btnlocation: UIButton!
    
    var feed : Feeds!{
        didSet{
            setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData() {
        if feed.imagePath != nil{
            imgProfile.sd_setImage(with: URL.init(string: feed.imagePath!), placeholderImage: ProfilePlaceholderImage)
        }
        else{
            imgProfile.image = ProfilePlaceholderImage
        }
        
        lblName.text = feed.fullName
        lblLocation.text = feed.location
        pageControl.numberOfPages = (feed.postImages?.count)!
        pageControl.currentPage = 0
        
        let attrString = feed.postDescIos?.html2AttributedString
        if feed.peopleTags!.count > 0{
            let arrNames = feed.peopleTags!.map({$0.fullName!})
            var strPeopleTag = "- With " + arrNames.first!
            if arrNames.count > 1{
                strPeopleTag = "\(strPeopleTag) and \(arrNames.count-1) others"
            }
            
            
            let attributedNames = NSMutableAttributedString(string:"\n \(strPeopleTag)")
            attributedNames.addAttribute(NSAttributedStringKey.font, value: UIFont.init(name: FT_Regular, size: 13)!, range: NSMakeRange(0, attributedNames.length))
            attributedNames.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attributedNames.length))
            
            let combination = NSMutableAttributedString()
            
            combination.append(attrString!)
            combination.append(attributedNames)
            lblCaption.attributedText = combination
        }else{
            lblCaption.attributedText = attrString
        }
        /*if (feed.postDesc?.contains("#"))!{
         lblCaption.attributedText = feed.postDescIos?.html2AttributedString
         }
         else {
         lblCaption.text = feed.postDesc
         }*/
        
        if feed.isLike == true {
            self.btnLike.setImage(UIImage.init(named: "liked_icon"), for: .normal)
        }
        else {
            self.btnLike.setImage(UIImage.init(named: "like_icon"), for: .normal)
        }
        
        let noOfTotalView : Int = feed.likeCount!
        self.lblNoOfLike.text = suffixNumber(number: NSNumber(value: noOfTotalView)) as String
        
        if feed.location?.count == 0{
            self.heightBtnLocation.constant = 0
            self.heightLblLocation.constant = 0
        }
        else {
            self.heightBtnLocation.constant = 25
            self.heightLblLocation.constant = 25
        }
        
        let commentCount = feed.commentCount!
        if commentCount == 0 {
            btnComment.setTitle("Add comments", for: .normal)
        }
        else {
            btnComment.setTitle("View all \(commentCount) comments", for: .normal)
        }
        
        //self.btnMore.addTarget(self, action: #selector(commentclicked), for: .touchUpInside)
        //self.btnLike.addTarget(self, action: #selector(commentclicked), for: .touchUpInside)
        //self.btnNoOfLike.addTarget(self, action: #selector(commentclicked), for: .touchUpInside)
        //self.btnComment.addTarget(self, action: #selector(commentclicked), for: .touchUpInside)
        
        //self.lblCaption.numberOfLines = 0
        //self.lblCaption.layoutIfNeeded()
        //self.lblaboutfeed.lineBreakMode = .byWordWrapping
        //self.lblaboutfeed.sizeToFit()
        
        //self.collposts.tag = indexPath.row
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        
        //Set Date
        var strDate = feed.creationDatetime!
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strDate) as Date
        strDate = timeAgoSinceDate(date: date, numericDates: true)
        lblTime.text = strDate
        
        //COMMENTED BECAUSE APP CRASHED IN SOME CASES WITH ERROR "attempt to scroll to invalid indexpath"
        //self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .left, animated: false)
    }
    
    @objc func commentclicked(_ sender:UIButton){
        let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idCommentsVC) as! CommentsVC
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
}

extension FeedListCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = feed.postImages![indexPath.row]
        let path = post.imagePath!
        
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
        return feed.postImages!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width:  SCREENWIDTH() - 11, height: collectionView.frame.height)
        //collectionView.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = Int(ceil(x/w))
            pageControl.currentPage = currentPage
        }
    }
    
}

