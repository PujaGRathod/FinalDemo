//
//  UITableView+Placeholder.swift
//  Heaconn
//
//  Created by C218 on 23/06/16.
//  Copyright © 2016 C81. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

let kPlaceholderRightPadding: CGFloat  = 10.0;
extension UITableView {
    func goToLastRow() {
        
        let lastSectionIndex = self.numberOfSections - 1
        if lastSectionIndex < 0 { //if invalid section
            return
        }
        
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        if lastRowIndex < 0 { //if invalid row
            return
        }
        
        let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        self.scrollToRow(at: pathToLastRow, at: .bottom, animated: false)
    }
}
public extension UITableView {
    
    func reloadDataWithPlaceholderString(placeholderString: String) {
        self.backgroundView = nil
        if self.numberOfSections == 0 || (self.numberOfRows(inSection: 0) == 0 || self.numberOfRows(inSection: 0) == NSNotFound) {
            if placeholderString.count > 0 {
                let lblEmpty: UILabel = self.getLabel()
                lblEmpty.text = placeholderString
                self.backgroundView = lblEmpty
            }
        }
        else {
            self.backgroundView = nil
        }
        self.reloadData()
    }

    func reloadDataWithPlaceholderString(placeholderString: String, lookupsection section: Int) {
        self.backgroundView = nil
        if self.numberOfSections == 0 && (self.numberOfRows(inSection: section) == 0 || self.numberOfRows(inSection: section) == NSNotFound) {
            if placeholderString.count > 0 {
                let lblEmpty: UILabel = self.getLabel()
                lblEmpty.text = placeholderString
                lblEmpty.textColor = UIColor.lightGray
                self.backgroundView = lblEmpty
            }
        }
        else {
            self.backgroundView = nil
        }
        self.reloadData()
    }
    
    func reloadDataWithPlaceholderString(placeholderString: String, withUIColor placeholderColor: UIColor) {
        self.backgroundView = nil
        if self.numberOfSections == 0 || (self.numberOfRows(inSection: 0) == 0 || self.numberOfRows(inSection: 0) == NSNotFound) {
            if placeholderString.count > 0 {
                let lblEmpty: UILabel = self.getLabel()
                lblEmpty.text = placeholderString
                lblEmpty.textColor = placeholderColor
                self.backgroundView = lblEmpty
            }
        }
        else {
            self.backgroundView = nil
        }
        self.reloadData()
    }
    
    func getLabel() -> UILabel {
        let lblEmpty: UILabel = UILabel(frame: CGRect(x:kPlaceholderRightPadding, y:kPlaceholderRightPadding, width:self.frame.width - kPlaceholderRightPadding - kPlaceholderRightPadding, height:self.frame.height - kPlaceholderRightPadding))
        lblEmpty.numberOfLines = 3
        lblEmpty.textAlignment = .center
        lblEmpty.lineBreakMode = .byWordWrapping
        lblEmpty.font = UIFont.systemFont(ofSize: 15.0)//THEME_FONT_MEDIUM(15.0)
        lblEmpty.sizeThatFits(lblEmpty.frame.size)
        return lblEmpty
    }
    
    func reloadDataWithPlaceholderImage(placeholderImage: UIImage?) {
        self.backgroundView = nil
        if self.numberOfSections == 0 || (self.numberOfRows(inSection: 0) == 0 || self.numberOfRows(inSection: 0) == NSNotFound) {
            if placeholderImage != nil {
                let img: UIImageView = UIImageView(frame: self.frame)
                img.image = placeholderImage
                img.backgroundColor = UIColor.clear
                img.contentMode = .scaleAspectFit
                self.backgroundView = img
            }
        }
        else {
            self.backgroundView = nil
        }
        self.reloadData()
    }
}

extension UIViewController
{
    func showAlertMessage(_ message: String, okButtonTitle: String = "Ok") -> Void
    {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
