//
//  VoiceCallVC.swift
//  WakeUppApp
//
//  Created by Admin on 09/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import TwilioVoice

class VoiceCallVC: UIViewController {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRinging: UILabel!
    
    @IBOutlet weak var imgbg: UIImageView!
    @IBOutlet weak var imgSpeaker: UIImageView!
    @IBOutlet weak var imgMic: UIImageView!
    @IBOutlet weak var vwDisconnect: UIView!
    
    var userID = ""
    var userName = ""
    var userMobile = ""
    var userPhoto = ""
    var timer = Timer()
    var speakerOn = false
    var seconds = 0
    var minutes = 0
    var redirectfrom = ""
    var callername = ""
    var usercountry = "91"
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurAboveImage(self.imgbg, 0.5)
        
        if redirectfrom == "Appdelegate"
        {
            lblName.text = callername
            if userPhoto.contains("http") == false{
                userPhoto = Get_Profile_Pic_URL + userPhoto
            }
            imgUser.sd_setImage(with: userPhoto.toUrl, placeholderImage: #imageLiteral(resourceName: "squareplaceholder"), options: [], completed: nil)
        }
        else
        {
            lblName.text = userName
            if userPhoto.contains("http") == false{
                userPhoto = Get_Profile_Pic_URL + userPhoto
            }
            imgUser.sd_setImage(with: userPhoto.toUrl, placeholderImage: #imageLiteral(resourceName: "squareplaceholder"), options: [], completed: nil)
            placeCall()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(callDidConnect(notification:)), name: NSNotification.Name(rawValue: NC_CallDidConnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callDidDisconnectConnect(notification:)), name: NSNotification.Name(rawValue: NC_CallDidDisConnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startCallAction(notification:)), name: NSNotification.Name(rawValue: NC_StartCallAction), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- BUTTON CLICKS
    @IBAction func btnSpeakerClicked(_ sender: Any) {
        if APP_DELEGATE.call != nil {
            speakerOn = !speakerOn
            toggleAudioRoute(toSpeaker: speakerOn)
        }
    }
    
    @IBAction func btnHangupClicked(_ sender: Any) {
        if (APP_DELEGATE.call != nil || APP_DELEGATE.call?.state == .connected) {
            APP_DELEGATE.call?.disconnect()
        }
        
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnMuteUnmuteClicked(_ sender: Any) {
        if let call = APP_DELEGATE.call {
            call.isMuted = !(call.isMuted)
            
            if (call.isMuted == true) {
                imgMic.image = #imageLiteral(resourceName: "mute_call_on")
            } else {
                imgMic.image = #imageLiteral(resourceName: "mute_call_off")
            }
        }
    }
    
    func placeCall(){
        /*outgoingName = "\(userID)_USER"
         let uuid = UUID()
         let handle = "\(identity)_USER"
         APP_DELEGATE.performStartCallAction(uuid: uuid, handle: handle)*/
        
        outgoingName = "\(userID)__\(usercountry)__\(userMobile)".replacingOccurrences(of: " ", with: "")
        
        let uuid = UUID()
        let handle = "\(identity)"
        APP_DELEGATE.performStartCallAction(uuid: uuid, handle: handle)
    }
    
    // MARK: AVAudioSession
    func toggleAudioRoute(toSpeaker: Bool) {
        
        // The mode set by the Voice SDK is "VoiceChat" so the default audio route is the built-in receiver. Use port override to switch the route.
        do {
            if (toSpeaker) {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                self.imgSpeaker.image = #imageLiteral(resourceName: "speaker_on")
            } else {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                self.imgSpeaker.image = #imageLiteral(resourceName: "speaker_off")
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    
    @objc func callDidConnect(notification:Notification)
    {
        toggleAudioRoute(toSpeaker: speakerOn)
        runTimer()
    }
    
    @objc func callDidDisconnectConnect(notification:Notification){
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    func runTimer()
    {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer()
    {
        seconds = seconds + 1
        if seconds == 60
        {
            minutes = minutes + 1
            seconds = 0
        }
        var l1 = "00"
        if minutes < 10
        {
            l1 = "0\(minutes)"
        }
        else
        {
            l1 = "\(minutes)"
        }
        var l2 = "00"
        if seconds < 10
        {
            l2 = "0\(seconds)"
        }
        else
        {
            l2 = "\(seconds)"
        }
        self.lblRinging.text = "Call Connected : \(l1):\(l2)"
    }
    @objc func startCallAction(notification:Notification){
        
    }
    
}

