//
//  OfficeInfoTblCell.swift
//  remone
//
//  Created by Arjav Lad on 19/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class OfficeInfoTblCell: UITableViewCell {

    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var imageViewInfo: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewInfo: UIView!

    private var imageViews: [UIImageView] = [UIImageView]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewInfo.isHidden = true
        self.scrollView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setInfo(with image: UIImage?, text: String?) {
        self.viewInfo.isHidden = false
        self.scrollView.isHidden = true
        self.imageViewInfo.image = image
        self.lblInfo.text = text
    }

    func addEquipments(_ equipments: [OfficeEquipment]) {
        self.viewInfo.isHidden = true
        self.scrollView.isHidden = false
        self.imageViews.removeAll()
        for subView in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(subView)
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
        self.stackView.addArrangedSubview(imageView)
    }

    private func generateImageView() -> UIImageView {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        return imageView
    }

    
}
