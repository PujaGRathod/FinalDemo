//
//  VideoPreviewCell.swift
//  ImageFilter
//
//  Created by Admin on 11/05/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class VideoPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoContainer: ASPVideoPlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBAction func btnPlayClicked(_ sender:UIButton){
        
        if videoContainer.status == .readyToPlay || videoContainer.status == .stopped {
            videoContainer.playVideo()
        }
        
        else if videoContainer.status == .playing{
            videoContainer.stopVideo()
        }
        
    }
    
}
