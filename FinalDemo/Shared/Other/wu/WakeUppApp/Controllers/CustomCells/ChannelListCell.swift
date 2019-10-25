//
//  ChannelListCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 14/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChannelListCell: UITableViewCell {
    
    @IBOutlet var vwmain: UIView!
    
    @IBOutlet var vwheading: UIView!
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var lblchannelname: UILabel!
    @IBOutlet var lblsubscribe: UILabel!
    @IBOutlet var lblpostedtime: UILabel!
    @IBOutlet var btndomore: UIButton!
    @IBOutlet var btnChannel: UIButton!
    
    @IBOutlet var vwchannel: UIView!
    @IBOutlet var imgpostimage: UIImageView!
    @IBOutlet var imgdropshadow: UIImageView!
    @IBOutlet var lbldescription: UILabel!
    @IBOutlet var lblNoOfView: UILabel!
    @IBOutlet var btntotalviewed: UIButton!
    @IBOutlet var btnplay: UIButton!
    
    @IBOutlet var vwactions: UIView!
    @IBOutlet var btnlikes: UIButton!
    @IBOutlet var btnNoOfLikes: UIButton!
    @IBOutlet var lblNoOfLike: UILabel!
    
    @IBOutlet var btncomments: UIButton!
    @IBOutlet var btnshare: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgdropshadow.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
