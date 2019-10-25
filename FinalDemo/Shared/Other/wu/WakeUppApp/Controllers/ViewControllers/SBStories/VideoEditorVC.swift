//
//  VideoEditorVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 06/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos
public protocol VideoEditorVCDelegate {
    func exportvideonow(_ url :URL);
}
class VideoEditorVC: UIViewController {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var btncancel: UIButton!
    
    @IBOutlet weak var btnDone: UIButton!
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var videoselected :AVAsset?
    var videourl:URL?
    var videoEditorVCDelegate: VideoEditorVCDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
         UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
     
        trimmerView.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trimmerView.asset = videoselected
        trimmerView.maxDuration = 30
        
        
        
        self.addVideoPlayer(with: videoselected!, playerView: playerView)
    }
    override func viewDidDisappear(_ animated: Bool) {
       //  UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
        player?.pause()
        player = nil
    }
    
    @IBAction func btndoneclicked(_ sender: Any)
    {
        let fileManager = FileManager.default
       
        let asset = videoselected!
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        //print("video length: \(length) seconds")
        var fileURL: URL? = getDocumentsDirectoryURL()
        fileURL?.appendPathComponent((videourl?.lastPathComponent)!)
        let outputURL = fileURL
        try? fileManager.removeItem(at: outputURL!)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: trimmerView.startTime!,
                                    end:  trimmerView.endTime!)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                //print("exported at \(String(describing: outputURL))")
                runOnMainThreadWithoutDeadlock {
                    //self.videoEditorVCDelegate?.exportvideonow(outputURL!)
                    let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: "idStoryPreviewVC") as! StoryPreviewVC
                    vc.vdourl = outputURL
                    APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                    //APP_DELEGATE.appNavigation?.popViewController(animated: true)
                }
            case .failed:
                //print("failed \(exportSession.error.debugDescription)")
                break
            case .cancelled:
                //print("cancelled \(exportSession.error.debugDescription)")
                break
            default: break
            }
        }
    }
    @IBAction func btncancelclicked(_ sender: Any)
    {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension VideoEditorVC
{
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
        //player?.play()
         trimmerView.asset = videoselected
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
            player?.play()
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker()
    {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker()
    {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
        }
    }
}
extension VideoEditorVC: TrimmerViewDelegate
{
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
        print(duration)
    }
}
