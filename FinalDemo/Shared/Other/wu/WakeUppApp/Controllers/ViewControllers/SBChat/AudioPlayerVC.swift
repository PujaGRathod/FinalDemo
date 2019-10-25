//
//  AudioPlayerVC.swift
//  WakeUppApp
//
//  Created by Admin on 13/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class AudioPlayerVC: UIViewController {

    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    var audioURL = ""
    var sliderTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.50) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    func setupSlider() {
        slider.maximumValue = Float( TPGAudioPlayer.sharedInstance().durationInSeconds )
        slider.minimumValue = 0.0
        
        if let _ = self.sliderTimer {
            sliderTimer?.invalidate()
        }
        
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AudioPlayerVC.sliderTimerTriggered), userInfo: nil, repeats: true)
        
        self.setupTotalTimeLabel()
    }
    
    @objc func sliderTimerTriggered() {
        let playerCurrentTime = TPGAudioPlayer.sharedInstance().currentTimeInSeconds
        
        slider.value = Float( playerCurrentTime )
        
        self.updateCurrentTimeLabel(Float( playerCurrentTime ))
        
        if playerCurrentTime == 0{
            btnPlay.setTitle("Play", for: .normal)
        }else{
            btnPlay.setTitle("Pause", for: .normal)
        }
    }
    
    func updateCurrentTimeLabel(_ currentTimeInSeconds: Float) {
        if currentTimeInSeconds.isNaN || currentTimeInSeconds.isInfinite {
            return
        }
        
        lblCurrentTime.text = timeLabelString( Int( currentTimeInSeconds ) )
    }
    
    func setupTotalTimeLabel() {
        let duration = TPGAudioPlayer.sharedInstance().durationInSeconds
        
        if duration.isNaN || duration.isInfinite {
            return
        }
        
        lblTotalTime.text = timeLabelString( Int (duration) )
    }
    
    func timeLabelString(_ duration: Int) -> String {
        let currentMinutes = Int(duration) / 60
        let currentSeconds = Int(duration) % 60
        
        return currentSeconds < 10 ? "\(currentMinutes):0\(currentSeconds)" : "\(currentMinutes):\(currentSeconds)"
    }
    
    func updatePlayButton() {
        let playOrPause = (TPGAudioPlayer.sharedInstance().isPlaying ? "Pause" : "Play")
        btnPlay.setTitle(playOrPause, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Button Clicks
    
    @IBAction func btnPlayClicked(_ sender: Any) {
        let fileName = audioURL.components(separatedBy: "/").last!
        let localURL = getDocumentsDirectoryURL()!.appendingPathComponent(fileName/*.replacingOccurrences(of: "mp3", with: "m4a").replacingOccurrences(of: "wav", with: "m4a")*/)
        
        let dictionary: Dictionary <String, AnyObject> = SpringboardData.springboardDictionary(title: "WakeUpp", artist: "WakeUpp", duration: Int (300.0), listScreenTitle: "Demo List Screen Title", imagePath: Bundle.main.path(forResource: "audio_player_image", ofType: "png")!)
        
        if isFileLocallySaved(fileUrl: localURL){
            TPGAudioPlayer.sharedInstance().playPauseMediaFile(audioUrl: localURL as NSURL, springboardInfo: dictionary, startTime: 0.0, completion: {(_ , stopTime) -> () in
                
                //self.hideLoadingIndicator()
                self.setupSlider()
                self.updatePlayButton()
            } )
        }
        else{
            TPGAudioPlayer.sharedInstance().playPauseMediaFile(audioUrl: URL(string: audioURL)! as NSURL, springboardInfo: dictionary, startTime: 0.0, completion: {(_ , stopTime) -> () in
                
                //self.hideLoadingIndicator()
                self.setupSlider()
                self.updatePlayButton()
            } )
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.50, animations: {
            self.view.backgroundColor = .clear
            TPGAudioPlayer.sharedInstance().seekPlayerToTime(value: 0, completion: nil)
            TPGAudioPlayer.sharedInstance().isPlaying = false
        }) { (finished) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if TPGAudioPlayer.sharedInstance().isPlaying {
            TPGAudioPlayer.sharedInstance().seekPlayerToTime(value: Double( sender.value ), completion: {() -> () in
                self.updatePlayButton()
            })
        }
    }

}
