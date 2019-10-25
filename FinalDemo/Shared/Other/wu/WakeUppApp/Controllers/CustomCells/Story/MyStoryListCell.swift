//
//  MyStoryListCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 31/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class MyStoryListCell: UITableViewCell
{
    @IBOutlet var vwbg: UIView!
    @IBOutlet var vwcontainer: UIView!
    @IBOutlet var imgpic: UIImageView!
    @IBOutlet var lbldate: UILabel!
    @IBOutlet var btntotalview: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        setupUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        setupUI()
    }
    
    func setupUI()
    {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.vwcontainer.backgroundColor = .white
        self.vwbg.backgroundColor = Color_Hex(hex: "F6EAEA")
    }
}
