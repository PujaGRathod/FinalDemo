//
//  DatePicker.swift
//  CookerCustomerApp
//
//  Created by Admin on 29/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit


class DatePicker:NSObject {
    
    static let sharedInstance: DatePicker = {
        let instance = DatePicker()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    let objDatePicker: UIDatePicker = UIDatePicker()
    public func showDateTimePicker(title:String,pickerMode:UIDatePickerMode,style:UIAlertControllerStyle,selectDate:@escaping (Date)->()) {
        
        
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 18)
        lblTitle.textAlignment = .center
        lblTitle.text = title
        objDatePicker.datePickerMode = pickerMode
        objDatePicker.timeZone = TimeZone.current
        objDatePicker.frame = CGRect(x: 0, y: 40, width: SCREENWIDTH() - 20, height: 220)
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: style)
        alertController.view.addSubview(lblTitle)
         alertController.view.addSubview(objDatePicker)
        let btnOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            selectDate(self.objDatePicker.date)
        })
        
        let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(btnOk)
        alertController.addAction(btnCancel)
        
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 380)
        alertController.view.addConstraint(alertControllerHeight);
        
        mostTopViewController?.present(alertController, animated: true)
    }
}
