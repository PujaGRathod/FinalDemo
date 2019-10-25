//
//  OfficeSearchListTblCell.swift
//  remone
//
//  Created by Arjav Lad on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class OfficeSearchListTblCell: UITableViewCell {

    @IBOutlet weak var stackViewEquipments: UIStackView!
    @IBOutlet weak var imgViewLocationPin: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var imgViewTimings: UIImageView!
    @IBOutlet weak var lblTimings: UILabel!
    @IBOutlet weak var viewTimings: UIView!
    @IBOutlet weak var imgViewOffice: UIImageView!
    @IBOutlet weak var lblPartneredOffice: UILabel!
    @IBOutlet weak var lblOfficeName: UILabel!

    private var imageViews: [UIImageView] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblPartneredOffice.layer.cornerRadius = 8
        self.lblPartneredOffice.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(for office: RMOffice) {
        self.lblOfficeName.text = office.name

        if office.location.address == "" {
            self.lblAddress.text = "-"
        } else  {
            self.lblAddress.text = office.location.address
        }

        if office.timings == "" {
            self.lblTimings.text = "-"
        } else  {
            self.lblTimings.text = office.timings
        }

        self.lblPartneredOffice.isHidden = !office.isPartnerShop
        self.imgViewOffice.sd_setImage(with: office.images.first) { (image, _, _, _) in
            self.imgViewOffice.image = image
        }
        self.addEquipments(office.equipments)
    }

    private func addEquipments(_ equipments: [OfficeEquipment]) {
        self.imageViews.removeAll()
        for subView in self.stackViewEquipments.arrangedSubviews {
            self.stackViewEquipments.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        for equipment in equipments {
                let imgView = self.generateImageView()
                imgView.layer.cornerRadius = 11
                imgView.layer.masksToBounds = true
                self.addImageView(imgView)
                self.imageViews.append(imgView)
            imgView.sd_setImage(with: equipment.imageURL, completed: { (image, _, _, _) in
                if let image = image {
                    imgView.image = image
                    
                }
            })
        }
    }

    private func addImageView(_ imageView: UIImageView) {
        self.stackViewEquipments.addArrangedSubview(imageView)
    }

    private func generateImageView() -> UIImageView {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        return imageView
    }
}
