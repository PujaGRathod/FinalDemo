//
//  VideoCell.swift
//  WakeUppApp
//
//  Created by Admin on 06/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

import AVFoundation
import MobileCoreServices
import Photos

public protocol VideoCellDelegate {
    func current_VideoTrimming(videoAsset: AVAsset,startTime:CMTime, endTime:CMTime)
}
extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
}
class VideoCell: UICollectionViewCell, TrimmerViewDelegate
{
    public var delegate: VideoCellDelegate?
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var btnPlayPause: UIButton!
    
    var player: AVPlayer?
    var videoselected :AVAsset?
    
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    
    var videourl:URL?
    var videoEditorVCDelegate: VideoEditorVCDelegate?
    
    let imgPlay : UIImage = #imageLiteral(resourceName: "play_btn")
    let imgPause : UIImage = #imageLiteral(resourceName: "ic_audio_pause")
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupUI() {
        trimmerView.delegate = self
        
        trimmerView.asset = videoselected
        trimmerView.maxDuration = 30
        
        self.addVideoPlayer(withAsset: videoselected!, playerView: self.playerView)
        
        self.btnPlayPause.setTitle("", for: .normal)
        self.btnPlayPause.setImage(imgPlay, for: .normal)
        self.btnPlayPause.setBackgroundImage(UIImage.init(), for: .normal)
        
//        self.startPlaybackTimeChecker()
//        self.didChangePositionBar(CMTime.init(value: 30, timescale: (videoselected?.duration.timescale)!))
    }
    
    func set_Current_VideoTrimming(startTime:CMTime, endTime:CMTime) {
        player?.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func set_Current_VideoTrimming(startTime:Double, endTime:Double) {
        let startTimeValue : CMTime = CMTime.init(seconds: startTime, preferredTimescale: (videoselected?.duration.timescale)!)
        //let stopTimeValue : CMTime = CMTime.init(seconds: endTime, preferredTimescale: (videoselected?.duration.timescale)!)
        
        player?.seek(to: startTimeValue, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    //MARK:- Buttonn action method
    @IBAction func btnPlayPauseAction() {
        if (player?.isPlaying == false)
        {
            player?.play()
            self.btnPlayPause.setImage(imgPause, for: .normal)
        }
        else {
            player?.pause()
            self.btnPlayPause.setImage(imgPlay, for: .normal)
        }
    }
    
    //MARK:- Manage Player
    private func addVideoPlayer(withAsset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: withAsset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.black.cgColor
        
        runAfterTime(time: 0.10) {
            layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        
            layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //layer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            playerView.layer.addSublayer(layer)
        }
        
        //player?.play()
        //self.btnPlayPause.setImage(self.imgPlay, for: .normal)
        //playerView.backgroundColor = UIColor.black
        
        self.trimmerView.asset = videoselected
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
            player?.play()
            self.btnPlayPause.setImage(imgPause, for: .normal)
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else { return }
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
            self.btnPlayPause.setImage(imgPause, for: .normal)
        }
    }
    
    //MARK:- TrimmerViewDelegate
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        //print("didChangePositionBar - duration : \(duration)")
        
        self.btnPlayPause.setImage(imgPause, for: .normal)
        
        self.delegate?.current_VideoTrimming(videoAsset: self.videoselected!,
                                             startTime: trimmerView.startTime!,
                                             endTime: trimmerView.endTime!)
    }
}
