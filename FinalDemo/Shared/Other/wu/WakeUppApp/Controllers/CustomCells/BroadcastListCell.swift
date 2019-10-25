//
//  BroadcastListCell.swift
//  WakeUppApp
//
//  Created by Admin on 31/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class BroadcastListCell: UITableViewCell {
    
    @IBOutlet var vwcontent: UIView!
    @IBOutlet var btnselected: UIButton!
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lbltime: UILabel!
    @IBOutlet var vwdetails: UIView!
    @IBOutlet var imgsound: UIImageView!
    @IBOutlet var soundWidth: NSLayoutConstraint!
    @IBOutlet var btncount: UIButton!
    @IBOutlet var lblgroupusername: UILabel!
    @IBOutlet var leadingmsg: NSLayoutConstraint!
    @IBOutlet var widthgroupuser: NSLayoutConstraint!
    @IBOutlet var widthreadreceipt: NSLayoutConstraint!
    @IBOutlet var widthmsgtype: NSLayoutConstraint!
    @IBOutlet var lblrecentmsg: UILabel!
    @IBOutlet var imgreceipt: UIImageView!
    @IBOutlet var imgmsgtype: UIImageView!
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
