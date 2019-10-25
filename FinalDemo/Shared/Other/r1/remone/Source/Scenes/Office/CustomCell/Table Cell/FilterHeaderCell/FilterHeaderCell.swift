//
//  FilterHeaderCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Arjav Lad. All rights reserved.
//

import UIKit

class FilterHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel! 
    @IBOutlet weak var bonttomSpace: NSLayoutConstraint!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func setTitle(title:String) {
        
        self.lblTitle.text = title
        if title == ""{
            self.bonttomSpace.constant = 0
        }else{
            self.bonttomSpace.constant = 12
        }
        
    }
}
