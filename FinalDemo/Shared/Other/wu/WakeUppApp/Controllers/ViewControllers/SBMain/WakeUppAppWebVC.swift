//
//  WakeUppAppWebVC.swift
//  WakeUppApp
//
//  Created by C025 on 25/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation

enum enumWebApp : Int {
    case enumWeb_None = 0
    case enumWeb_LoginNow
    case enumWeb_LogOutNow
}

class WakeUppAppWebVC: UIViewController {
    //MARK: Outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var viewScanQRCode: UIView!
    @IBOutlet weak var lc_viewScanQRCode_x: NSLayoutConstraint!
    @IBOutlet weak var viewScan: UIView!
    
    @IBOutlet weak var viewLogout: UIView!
    @IBOutlet weak var lc_viewLogout_x: NSLayoutConstraint!
    
    @IBOutlet weak var imgLastLogin: UIImageView!
    @IBOutlet weak var lblLastLogin_Date: UILabel!
    @IBOutlet weak var lblLastLogin_Computer: UILabel!
    @IBOutlet weak var btnLastLogin: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    //MARK: Variable
    let duration_animation = 0.50
    
    var objEnumWebApp : enumWebApp = .enumWeb_None
    
    // --->
    // For User Scan QR Code
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Default both possion
        //self.lc_viewScanQRCode_x.constant = SCREENWIDTH()
        //self.lc_viewLogout_x.constant = SCREENWIDTH()
        //self.view.layoutIfNeeded()
        
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Custom function
    func setupUI() {
        self.view.endEditing(true)
        
        var strTitle : String = ""
        switch self.objEnumWebApp {
        case .enumWeb_None: break
        case .enumWeb_LoginNow:
            strTitle = "Scan Code"
            btnAdd.isHidden = true
            
            runAfterTime(time: duration_animation/2) {
                self.manange_QRCideScanView()
            }
            break
        case .enumWeb_LogOutNow:
            strTitle = "\(APPNAME + "Web")"
            self.btnAdd.isHidden = false
            
            self.lc_viewScanQRCode_x.constant = SCREENWIDTH()
            self.view.layoutIfNeeded()
            
            break
        }
        
        //Set Title
        self.btnBack.setTitle(strTitle, for: .normal)
    }
    
    //MARK: Manage QRCode Scan View
    func manange_QRCideScanView() -> Void {
        self.captureSession = nil
        self.startStopReading()
    }
    
    func startReading() -> Bool {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        guard (captureDevice?.deviceType.hashValue) != nil else {
            //print("Failed to get the open camera")
            showMessage("Failed to get the open camera")
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print(error)
            showMessage(error.localizedDescription)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = viewScan.layer.bounds
        viewScan.layer.addSublayer(videoPreviewLayer)
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        print(captureMetadataOutput.availableMetadataObjectTypes)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
        
        return true
    }
    
    @objc func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    func startStopReading() {
        if !isReading {
            if (self.startReading()) {
                //showMessage("Scanning for QR Code...")
            }
        }
        else { stopReading() }
        isReading = !isReading
    }
    
    func manage_readedQRCode(qrCodeMess : String) {
        //Set Default Position (Hide into screen)
        self.lc_viewScanQRCode_x.constant = SCREENWIDTH()
        self.view.layoutIfNeeded()
        btnAdd.isHidden = false
        
        //------------------>
        //Show Scan QR Code Data
        var alert : UIAlertController = UIAlertController.init()
        alert = UIAlertController(title: nil, message: qrCodeMess, preferredStyle: .alert)
        /*alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            //-----> Manage Action
        }))*/
        //Dismiss-OR-Cancel alert action.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Dismiss Confirmation Alert")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnAddAction() {
        self.manange_QRCideScanView()
        
        UIView.animate(withDuration: duration_animation, animations: {
            self.lc_viewScanQRCode_x.constant = 0
            self.view.layoutIfNeeded()
        }) { (success : Bool) in
            self.btnAdd.isHidden = true //Hide Add Button
            self.btnBack.setTitle("Scan Code", for: .normal) //Set Title
        }
    }
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        var alert : UIAlertController = UIAlertController.init()
        if (sender == btnLastLogin) {
            alert = UIAlertController(title: APPNAME, message: "Are you sure you want to Log out for this computer?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                showMessage("Work in Progress...")
                
                /*//Called Web API
                 let parameter:NSDictionary = ["service":API...,
                 "request":["post_id": ""],
                 "auth" : getAuthForService()]
                 self.api_(parameter: parameter)*/
            }))
        }
        else if (sender == btnLogout) {
            alert = UIAlertController(title: APPNAME, message: "Are you sure you want to all Log out from all computer?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                showMessage("Work in Progress...")
                
                /*//Called Web API
                 let parameter:NSDictionary = ["service":API...,
                 "request":["post_id": ""],
                 "auth" : getAuthForService()]
                 self.api_(parameter: parameter)*/
            }))
        }
        //Dismiss-OR-Cancel alert action.
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Dismiss Confirmation Alert")
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension WakeUppAppWebVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        for data in metadataObjects {
            let metaData = data
            print(metaData.description)
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwrapedStringValue = transformed?.stringValue {
                self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
                isReading = false;
                
                //print("result: \(unwrapedStringValue)")
                self.manage_readedQRCode(qrCodeMess: unwrapedStringValue)
            }
        }
    }
}
