//
//  ImageCropperVC.swift
//  WakeUppApp
//
//  Created by Admin on 24/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IGRPhotoTweaks

class ImageCropperVC: IGRPhotoTweakViewController {

    var shouldSquare = true
    var shouldBackgroundOfChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldSquare{
            self.setCropAspectRect(aspect: "1:1")
            self.lockAspectRatio(true)
        }
        else{
            self.resetAspectRect()
        }
        
        //PV
        if shouldBackgroundOfChat {
            self.setCropAspectRect(aspect: "2:3")
            self.lockAspectRatio(true)
            
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        dismissAction()
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        cropAction()
    }
    
    override open func customCanvasHeaderHeigth() -> CGFloat {
        var heigth: CGFloat = 0.0
        if UIDevice.current.orientation.isLandscape {
            heigth = 40.0
        } else {
            heigth = 100.0
        }
        
        return heigth
    }
    
}
