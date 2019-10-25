//
//  RequestTblCell.swift
//  remone
//
//  Created by Arjav Lad on 29/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
protocol  RequestTblCellDelegate{
    func acceptedRequest(index:NSInteger)
    func rejectedRequest(index:NSInteger)
}

class RequestTblCell: UITableViewCell {
    var delegate: RequestTblCellDelegate?
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgViewProfile: UIImageView!
    var index:NSInteger!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.imgViewProfile.layer.cornerRadius = 20
        self.imgViewProfile.clipsToBounds = true
        self.imgViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imgViewProfile.layer.borderWidth = 0.5

        self.btnDelete.layer.cornerRadius = 14
        self.btnDelete.layer.borderWidth = 1
        self.btnDelete.layer.borderColor = self.btnDelete.tintColor.cgColor
        self.btnApprove.layer.cornerRadius = 14
        self.btnApprove.clipsToBounds = true
        self.btnDelete.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onDeleteTap(_ sender: UIButton) {
        print("btnDelete click")
        self.delegate?.rejectedRequest(index: self.index)
    }

    @IBAction func onApproveTap(_ sender: UIButton) {
        print("btnApprove click")        
        self.delegate?.acceptedRequest(index: self.index)
    }
}
