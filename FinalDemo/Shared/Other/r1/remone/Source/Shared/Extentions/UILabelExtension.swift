//
//  UILabelExtension.swift
//  remone
//
//  Created by Arjav Lad on 20/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        if let text = self.text {
            return text.height(withConstrainedWidth: width, font: self.font)
        } else if let aText = self.attributedText {
            return aText.height(withConstrainedWidth: width)
        } else {
            return 0
        }
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        if let text = self.text {
            return text.width(withConstrainedHeight: height, font: self.font)
        } else if let aText = self.attributedText {
            return aText.width(withConstrainedHeight: height)
        } else {
            return 0
        }
    }
}
