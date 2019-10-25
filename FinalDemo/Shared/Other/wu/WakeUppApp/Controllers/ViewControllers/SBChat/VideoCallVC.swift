//
//  VideoCallVC.swift
//  WakeUppApp
//
//  Created by Admin on 09/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import TwilioVideo

class VideoCallVC: UIViewController {
    
    var accessToken = "TWILIO_ACCESS_TOKEN"
    
    // Video SDK Components
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var remoteParticipant: TVIRemoteParticipant?
    
    //MARK:- IBOutlets
    @IBOutlet weak var remoteView: TVIVideoView!
    @IBOutlet weak var previewView: TVIVideoView!
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRingingOrIncoming: UILabel!
    
    
    @IBOutlet weak var vwCamera: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var vwDisconnect: UIView!
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var vwMic: UIView!
    @IBOutlet weak var imgMic: UIImageView!
    @IBOutlet weak var micButton: UIButton!
    
    @IBOutlet weak var vwmain: UIView!
    @IBOutlet weak var imgbg: UIImageView!
    
    @IBOutlet weak var lblbg: UILabel!
    @IBOutlet weak var vwAccept: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var vwReject: UIView!
    @IBOutlet weak var rejectButton: UIButton!
    
    //MARK:- Properties
    var userID = ""
    var userName = ""
    var userPhoto = ""
    
    var isReceivedCall = true
    var roomName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPreview()
        
        lblName.text = userName
        addBlurAboveImage(self.imgbg, 0.5)
        if isReceivedCall{
            lblRingingOrIncoming.text = "Incoming call"
            
            vwDisconnect.isHidden = true
            
            vwReject.isHidden = false
            vwAccept.isHidden = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            saveCallInLocalDB(status: "missed", callID: appDelegate.getUniquieNo())
        }else{
            roomName = randomString(length: 30)
            connect()
            
            vwDisconnect.isHidden = false
            
            vwReject.isHidden = true
            vwAccept.isHidden = true
        }
        
        imgUser.sd_setImage(with: userPhoto.toUrl, placeholderImage: #imageLiteral(resourceName: "profile_pic_register"), options: [], completed: nil)
        
        APP_DELEGATE.socketIOHandler?.socket?.on("VideoCallRejected", callback: { (data, ack) in
            self.closeVideoCall()
        })
        
        APP_DELEGATE.socketIOHandler?.socket?.on("VideoCallCancelled", callback: { (data, ack) in
            self.localAudioTrack?.isEnabled = false
            self.localVideoTrack?.isEnabled = false
            APP_DELEGATE.appNavigation?.popViewController(animated: false)
            //self.closeVideoCall()
        })
        
    }
    
    func closeVideoCall(){
        //APP_DELEGATE.appNavigation?.popViewController(animated: true)
        localAudioTrack?.isEnabled = false
        APP_DELEGATE.appNavigation?.backToViewController(viewController: ChatVC.self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect() {
        vwAccept.isHidden = true
        if isReceivedCall{
            lblRingingOrIncoming.text = "Connecting..."
        }
        // Configure access token either from server or manually.
        // If the default wasn't changed, try fetching from server.
        if (accessToken == "TWILIO_ACCESS_TOKEN") {
            do {
                accessToken = try TokenUtils.fetchToken(forRoomName: roomName)
            } catch {
                let message = "Failed to fetch access token"
                logMessage(messageText: message)
                return
            }
        }
        
        
        // Prepare local media which we will share with Room Participants.
        self.prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
            
            // Use the preferred audio codec
            if let preferredAudioCodec = VideoCallSettings.shared.audioCodec {
                builder.preferredAudioCodecs = [preferredAudioCodec]
            }
            
            // Use the preferred video codec
            if let preferredVideoCodec = VideoCallSettings.shared.videoCodec {
                builder.preferredVideoCodecs = [preferredVideoCodec]
            }
            
            // Use the preferred encoding parameters
            if let encodingParameters = VideoCallSettings.shared.getEncodingParameters() {
                builder.encodingParameters = encodingParameters
            }
            
            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            builder.roomName = self.roomName
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
        
        logMessage(messageText: "Attempting to connect to room \(roomName)")
        
        self.showRoomUI(inRoom: true)
        
    }
    
    //MARK:- BUTTON CLICKS
    @IBAction func btnSwitchCameraClicked(_ sender: Any) {
        flipCamera()
    }
    
    @IBAction func btnHangupClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.cancelCall()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.disconnectRoom()
            APP_DELEGATE.appNavigation?.popViewController(animated: true)
            //self.closeVideoCall()
        })
    }
    
    func cancelCall(){
        if isReceivedCall == false{
            let dict = [
                "callToId":userID,
                "callToName":userName,
                "callToPhoto":userPhoto,
                "roomname":roomName,
                "callerId":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                "callerName":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "callerPhoto":UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
            ]
            APP_DELEGATE.socketIOHandler?.socket?.emit("Cancel_call",dict)
        }
    }
    
    @IBAction func btnMuteUnmuteClicked(_ sender: Any) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            if (self.localAudioTrack?.isEnabled == true) {
                imgMic.image = #imageLiteral(resourceName: "mute_call_off")
            } else {
                imgMic.image = #imageLiteral(resourceName: "mute_call_on")
            }
        }
    }
    
    @IBAction func btnAcceptClicked(_ sender: Any) {
        if let strId = UserDefaults.standard.object(forKey: "uniqueid") as? String {
            saveCallInLocalDB(status: "incoming", callID: strId)
        }
        connect()
    }
    
    @IBAction func btnRejectClicked(_ sender: Any) {
        disconnectRoom()
        let dict = [
            "callToId":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "callToName":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "callToPhoto":UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile),
            "roomname":roomName,
            "callerId":userID,
            "callerName":userName,
            "callerPhoto" : userPhoto
        ]
        APP_DELEGATE.socketIOHandler?.socket?.emit("Reject_call",dict)
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    //MARK:- METHODS
    
    func disconnectRoom(){
        if let joinedRoom = room{
            joinedRoom.disconnect()
            logMessage(messageText: "Attempting to disconnect from room \(joinedRoom.name)")
            //room?.localParticipant?.localAudioTracks.forEach({$0.localTrack?.isEnabled=false})
            localAudioTrack?.isEnabled = false
        }
    }
    
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        localVideoTrack = TVILocalVideoTrack.init(capturer: camera!, enabled: true, constraints: nil, name: "Camera")
        if (localVideoTrack == nil) {
            logMessage(messageText: "Failed to create video track")
        } else {
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            
            logMessage(messageText: "Video track created")
            
            // We will flip camera on tap.
            let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }
    
    @objc func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }
    
    func prepareLocalMedia() {
        
        // We will share local audio and video when we connect to the Room.
        
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = TVILocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
            
            if (localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }
        
        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startPreview()
        }
    }
    
    // Update our UI based upon if we are in a Room or not
    func showRoomUI(inRoom: Bool) {
        
        if inRoom{
            vwCamera.isHidden = false
            vwMic.isHidden = false
        }
        
        //self.cameraButton.isHidden = !inRoom
        //self.disconnectButton.isHidden = !inRoom
        //self.micButton.isHidden = !inRoom
        //UIApplication.shared.isIdleTimerDisabled = inRoom
    }
    
    func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.remoteView!)
                self.remoteView?.removeFromSuperview()
                self.remoteView = nil
            }
        }
        closeVideoCall()
        self.remoteParticipant = nil
    }
    
    func logMessage(messageText: String) {
        print(messageText)
    }
    
}

// MARK: TVIRoomDelegate
extension VideoCallVC : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
        logMessage(messageText: "Connected to room \(room.name) as \(String(describing: room.localParticipant?.identity))")
        
        if isReceivedCall{
            //vwCallerControls.isHidden = false
            //vwReceiverControls.isHidden = true
            vwDisconnect.isHidden = false
            
            vwReject.isHidden = true
            vwAccept.isHidden = true
            
        }else{
            if let isConnected = APP_DELEGATE.socketIOHandler?.isSocektConnected(){
                if isConnected == true{
                    let dict = [
                        "callToId":userID,
                        "callToName":userName,
                        "callToPhoto":userPhoto,
                        "roomname":roomName,
                        "callerId":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                        "callerName":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                        "callerPhoto":UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
                    ]
                    APP_DELEGATE.socketIOHandler?.socket?.emit("Send_RoomName",dict)
                }
            }
        }
        
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        logMessage(messageText: "Disconncted from room \(room.name), error = \(String(describing: error))")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        logMessage(messageText: "Failed to connect to room with error : \(error.localizedDescription)")
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }else{
            closeVideoCall()
        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIRemoteParticipantDelegate
extension VideoCallVC : TVIRemoteParticipantDelegate {
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has stopped sharing the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has offered to share the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has stopped sharing the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }
    
    func subscribed(to videoTrack: TVIRemoteVideoTrack,
                    publication: TVIRemoteVideoTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's video frames now.
        
        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            //setupRemoteVideoView()
            videoTrack.addRenderer(self.remoteView!)
            lblName.text = ""
            lblRingingOrIncoming.text = ""
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack,
                      publication: TVIRemoteVideoTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.remoteView!)
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
            disconnectRoom()
        }
    }
    
    func subscribed(to audioTrack: TVIRemoteAudioTrack,
                    publication: TVIRemoteAudioTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
        
        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func unsubscribed(from audioTrack: TVIRemoteAudioTrack,
                      publication: TVIRemoteAudioTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }
    
    func failedToSubscribe(toAudioTrack publication: TVIRemoteAudioTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }
    
    func failedToSubscribe(toVideoTrack publication: TVIRemoteVideoTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK: TVIVideoViewDelegate
extension VideoCallVC : TVIVideoViewDelegate {
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: TVICameraCapturerDelegate
extension VideoCallVC : TVICameraCapturerDelegate {
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
}

extension VideoCallVC {
    func saveCallInLocalDB(status: String, callID: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dictCall = [
            //"image":"\(Get_Profile_Pic_URL)\(userPhoto)",
            "image":"\(userPhoto)",
            "name":userName,
            "status":status,
            "is_video_call":"1",
            "call_from":"",
            "call_to":"",
            "call_id":callID,
            "date":appDelegate.getCurrentTime(),
            ]  as [String : Any]
        
        appDelegate.storeCallLog(dictCall: dictCall)
    }
}

