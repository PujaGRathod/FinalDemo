//
//  FilterSelectionCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Arjav Lad. All rights reserved.
//

import UIKit

class FilterSelectionCell: UITableViewCell {
    
    @IBOutlet weak var viewTitleImage: UIView!
    @IBOutlet weak var imgTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewCheckUncheck: UIView!
    @IBOutlet weak var imgCheckUncheck: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isSelectedFilter(false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupData(seatType:OfficeSeatingType)  {
        self.lblTitle.text = seatType.name
        if let imageURL = seatType.imageURL {
            self.imgTitle.sd_setImage(with: imageURL, completed: { (image, _, _, _) in
                self.imgTitle.image = image
            })
        } else {
            self.imgTitle.image = seatType.image
        }
        self.isSelectedFilter(true)
    }
    
    func setupData(officeEquipment: OfficeEquipment)  {
        self.imgTitle?.image = nil
        self.lblTitle.text = officeEquipment.name
        self.imgTitle.sd_setImage(with: officeEquipment.imageURL, completed: { (image, _, _, _) in
            self.imgTitle.image = image
        })
        self.isSelectedFilter(true)
    }

    func isSelectedFilter(_ isSelected:Bool)  {
        self.viewCheckUncheck.isHidden = !isSelected
    }

}
