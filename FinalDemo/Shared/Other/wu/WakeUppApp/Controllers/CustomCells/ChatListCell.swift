//
//  ChatListCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 22/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
//import SimpleImageViewer
class ChatListCell: MGSwipeTableCell {

    //***************************>
    @IBOutlet var vwcontent: UIView!
    
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet weak var imgHiddenChat: UIImageView!
    
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lbltime: UILabel!
    
    //--*--*--*--*--*-->
    @IBOutlet var vwdetails: UIView!
    
    @IBOutlet var lblgroupusername: UILabel!
    @IBOutlet var widthgroupuser: NSLayoutConstraint!
    
    @IBOutlet var imgreceipt: UIImageView!
    @IBOutlet var widthreadreceipt: NSLayoutConstraint!
    
    @IBOutlet var imgmsgtype: UIImageView!
    @IBOutlet var widthmsgtype: NSLayoutConstraint!
    
    @IBOutlet var lblrecentmsg: UILabel!
    @IBOutlet var leadingmsg: NSLayoutConstraint!
    //<--*--*--*--*--*--
    
    @IBOutlet var btncount: UIButton!
    
    @IBOutlet var imgsound: UIImageView!
    @IBOutlet var soundWidth: NSLayoutConstraint!
    
    @IBOutlet var imgPin: UIImageView!
    @IBOutlet var widthPin : NSLayoutConstraint!
    
    @IBOutlet var btnselected: UIButton!
    //<***************************
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        //pu
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageProfileClicked(_:)))
        imgprofile.isUserInteractionEnabled = true
        imgprofile.addGestureRecognizer(tapGestureRecognizer)
        //end
    }
    @objc func imageProfileClicked(_ sender:UITapGestureRecognizer){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = sender.view as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
