//
//  FeedVideoCell.swift
//  WakeUppApp
//
//  Created by Admin on 01/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation

class FeedVideoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgVideoThumb: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var videoContainer: ASPVideoPlayerView!
    
    var post : PostImages!{
        didSet{
            
            
            //Set ThumbImage of Video
            //New Suggested by Payal U.
            var strURL : String = post.postImage!
            if (strURL.count != 0) {
                let arrDetectPostType : NSArray = strURL.components(separatedBy: ".") as NSArray
                strURL = arrDetectPostType.firstObject as! String
                strURL += "_thumb.jpg"
                strURL = "\(PostImage_URL + "/" + strURL)"
                //print("Video thumb Image : \(strURL)")
                //imgVideoThumb.sd_setImage(with: URL.init(string: strURL), placeholderImage: SquarePlaceHolderImage)
            }
            
            videoContainer.gravity = .aspectFill//.aspectFit
            videoContainer.stopVideo()
            //videoContainer.videoURL = URL.init(string: post.imagePath!)
            
            let url = URL.init(string: post.imagePath!)!
            if isFileLocallySaved(fileUrl: url){
                videoContainer.videoURL = getLocallySavedFileURL(with: url)
            }
            else{
                videoContainer.videoAsset = AVURLAsset.init(url: url)
            }
            //videoContainer.playVideo()
            
            btnPlay.addTarget(self, action: #selector(btnPlayClicked(_:)), for: .touchUpInside)
            
            videoContainer.stoppedVideo = {
                self.btnPlay.isHidden = false
            }
            
        }
    }
    
    @objc func btnPlayClicked(_ sender : UIButton){
        if videoContainer.status == .readyToPlay || videoContainer.status == .stopped{
            videoContainer.playVideo()
            self.btnPlay.isHidden = true
        }
    }
    
}

