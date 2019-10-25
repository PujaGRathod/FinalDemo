//
//  ChatWallpaperSetVC.swift
//  WakeUppApp
//
//  Created by PiyushVyas on 28/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChatWallpaperSetVC: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var imgSetBackgroundImage: UIImageView!
    
    // MARK: - Variable
    var setBGImage : UIImage = #imageLiteral(resourceName: "filterpic")
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgSetBackgroundImage.image = setBGImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button action method
    @IBAction func btnBackAction(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    @IBAction func btnSetAction(_ sender: Any) {
        //Save  Image
        if saveFileDataLocally(data: UIImageJPEGRepresentation(self.imgSetBackgroundImage.image!, 1.0)!, with: kChatWallpaper) {
            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsChatWallpaperSet)
        }
        self.btnCancelAction(UIButton.init())
    }
}
