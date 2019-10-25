//
//  FeedCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 23/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol FeedCellDelegate
{
    func collvw(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collvw(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collvw(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}
class FeedCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet var pgpost: UIPageControl!
    @IBOutlet var btnmore: UIButton!
    @IBOutlet var vwmain: UIView!
    @IBOutlet var vwheading: UIView!
    @IBOutlet var vwfeed: UIView!
    @IBOutlet var vwactions: UIView!
    @IBOutlet var lbltime: UILabel!
    @IBOutlet var heightlocation: NSLayoutConstraint!
    @IBOutlet var lblfeeduser: UILabel!
    @IBOutlet var lblaboutfeed: UILabel!
    @IBOutlet var collposts: UICollectionView!
    @IBOutlet var lbllocation: UILabel!
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var btnlike: UIButton!
    @IBOutlet var btnshare: UIButton!
    @IBOutlet var btncomment: UIButton!
    
    var delegate: FeedCellDelegate?
    
    var feeds : Feeds!{
        didSet{
            self.lbltime.text = "2d ago"
            if feeds.image != nil
            {
                self.imgprofile.sd_setImage(with: URL.init(string: feeds.image!), placeholderImage: ProfilePlaceholderImage)
            }
            else
            {
                self.imgprofile.image = ProfilePlaceholderImage
            }
            self.lblfeeduser.text = feeds.fullName
            self.lbllocation.text = feeds.location
            self.pgpost.numberOfPages = (feeds.postImages?.count)!
            self.pgpost.currentPage = 0
            // self.lblaboutfeed.backgroundColor = UIColor.red
            if (feeds.postDesc?.contains("#"))!
            {
                self.lblaboutfeed.attributedText = feeds.postDesc?.html2AttributedString
            }
            else
            {
                self.lblaboutfeed.text = feeds.postDesc
            }
            arrImages = feeds.postImages!
            if feeds.isLike == true
            {
                self.btnlike.setImage(UIImage.init(named: "liked_icon"), for: .normal)
            }
            else
            {
                self.btnlike.setImage(UIImage.init(named: "like_icon"), for: .normal)
            }
            print(feeds.postDesc ?? "")
            if feeds.location?.count == 0
            {
                self.heightlocation.constant = 0
            }
            else
            {
                self.heightlocation.constant = 25
            }
            let commentCount = feeds.commentCount!
            if commentCount == 0{
                btncomment.setTitle("\(commentCount) comments", for: .normal)
            }else{
                btncomment.setTitle("View all \(commentCount) comments", for: .normal)
            }
            
            self.btncomment.addTarget(self, action: #selector(commentclicked), for: .touchUpInside)
                    self.lblaboutfeed.numberOfLines = 0
                    //self.lblaboutfeed.lineBreakMode = .byWordWrapping
                    //self.lblaboutfeed.sizeToFit()
                    self.lblaboutfeed.layoutIfNeeded()
            //self.collposts.tag = indexPath.row
            self.collposts.reloadData()
        }
    }
    var arrImages = [PostImages]()
    /*var player = AVPlayer.init()
    var playerLayer = AVPlayerLayer.init()*/
    
    
    //MARK: - Accessors
    
    var player: AVPlayer {
        get{
            let player: AVPlayer = AVPlayer(playerItem: self.playerItem)
        
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
            return player
        }
        set{
            //self.player = newValue
        }
    }
    
    var playerItem: AVPlayerItem  {
        get{
            let playerItem: AVPlayerItem = AVPlayerItem(asset: self.asset)
            return playerItem
        }set{
            //self.playerItem = newValue
        }
    }
    
    var asset: AVURLAsset {
        get{
            let asset: AVURLAsset = AVURLAsset(url: self.url)
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            return asset
        }set{
            //self.asset = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        get{
            let playerLayer: AVPlayerLayer = AVPlayerLayer(player: self.player)
        
            playerLayer.frame = UIScreen.main.bounds
            playerLayer.backgroundColor = UIColor.clear.cgColor
        
            return playerLayer
        }
        set{
            //self.playerLayer = newValue
        }
    }
    
    var url: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pgpost.currentPage = 0
        self.collposts.delegate = self
        self.collposts.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func commentclicked(_ sender:UIButton){
        let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idCommentsVC) as! CommentsVC
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    //MARK: CollectionView Delegate and Datasource

    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrImages.count// (delegate?.collvw(collectionView,numberOfItemsInSection:section))!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellpost", for: indexPath as IndexPath)
        
        let imgView = cell.viewWithTag(100) as! UIImageView
        imgView.layer.sublayers?.removeAll()
        imgView.image = nil
        
        let btnPlay = cell.viewWithTag(200) as! UIButton
        btnPlay.isHidden = true
        btnPlay.accessibilityLabel = "\(indexPath.row)"
        
        let obj = arrImages[indexPath.item]
        
        if isPathForVideo(path: obj.imagePath!){
            btnPlay.isHidden = false
            btnPlay.addTarget(self, action: #selector(btnPlayClicked), for: .touchUpInside)
            //print("//PLAY VIDEO IN IMAGE_VIEW HERE")
            print(obj.imagePath!)
            imgView.backgroundColor = .black
            
            self.url = URL.init(string: obj.imagePath!)!
            if isFileLocallySaved(fileUrl: self.url){
                self.url = getLocallySavedFileURL(with: self.url)
            }
            
            let avAsset = AVAsset.init(url: self.url)
            let playerItem = AVPlayerItem(asset: avAsset)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            imgView.layer.addSublayer(playerLayer)
            playerLayer.frame = imgView.bounds
            self.layoutIfNeeded()
            player.seek(to: kCMTimeZero)
            //player.play()
            /*DispatchQueue.main.async {
                let asset = AVAsset(url: URL(string: obj.imagePath!)!)
                let durationSeconds = CMTimeGetSeconds(asset.duration)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                
                let time = CMTimeMakeWithSeconds(durationSeconds/3.0, 600)
                
                let nsValue = NSValue.init(time: time)
                generator.generateCGImagesAsynchronously(forTimes: [nsValue], completionHandler: { (Time, thumbnail, actualTime, result, error) in
                    DispatchQueue.main.async {
                        let img = UIImage.init(cgImage:thumbnail!)
                        self.imageView?.image = img
                    }
                })
            }*/
        }else{
            imgView.sd_setImage(with: URL.init(string:obj.imagePath!), placeholderImage: PlaceholderImage)
        }
        return cell
        //return (delegate?.collvw(collectionView,cellForItemAt:indexPath))!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //delegate?.collvw(collectionView, didSelectItemAt: indexPath)
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
            self.pgpost.currentPage = currentPage
        }
    }
    
    @objc func btnPlayClicked(_ sender: UIButton){
        print()
        /*let url = URL.init(string: feeds.postImages![Int("\(sender.accessibilityLabel!)")!].imagePath!)!
        let asset = AVURLAsset.init(url: url)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let playerItem = AVPlayerItem.init(asset: asset)
        let player = AVPlayer.init(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        APP_DELEGATE.appNavigation?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }*/
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        APP_DELEGATE.appNavigation?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
        //NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        
        if notification.object is AVPlayerItem{
            
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            
            let filename = url.lastPathComponent
            
            let documentsDirectory = FileManager.default.getDocumentsDirectory()
            
            let outputURL = documentsDirectory.appendingPathComponent(filename)
            
            let localURL = URL.init(fileURLWithPath: outputURL)
            
            if isFileLocallySaved(fileUrl: url) == false{
                showHUD()
                exporter?.outputURL = localURL
                exporter?.outputFileType = .mp4
            
                exporter?.exportAsynchronously(completionHandler: {
                    print(exporter?.status.rawValue ?? "")
                    print(exporter?.error ?? "")
                    hideHUD()
                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension FeedCell : AVAssetResourceLoaderDelegate {
    
}
