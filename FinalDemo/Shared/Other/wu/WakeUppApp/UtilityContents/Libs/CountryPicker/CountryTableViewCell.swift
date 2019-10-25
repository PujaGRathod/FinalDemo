//
//  CountryTableViewCell.swift
//  CountryList-Swift
//
//  Created by Sai Ram Kotha on 29/01/16.
//
//

import UIKit

class CountryTableViewCell: UITableViewCell {
  
    @IBOutlet var imgFlag: UIImageView!
    @IBOutlet var lblnamecountry: UILabel!
    @IBOutlet var lblcode: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    self.imgFlag.layer.cornerRadius = 3
    self.imgFlag.layer.borderColor = UIColor.lightGray.cgColor
    self.imgFlag.layer.borderWidth = 1
    self.imgFlag.clipsToBounds = true
  }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
//  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//     super.init(style: .value1, reuseIdentifier: reuseIdentifier) 
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//  }
//  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    if selected {
      self.accessoryType = .checkmark
    }else{
      self.accessoryType = .none
    }
  }
  
}
