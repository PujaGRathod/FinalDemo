//
//  PickerControl.swift
//  CookerApp
//
//  Created by Admin on 19/01/18.
//  Copyright © 2018 EL. All rights reserved.
//

import Foundation
import UIKit

class PickerControl:NSObject,UIPickerViewDataSource,UIPickerViewDelegate
{
    var selectedLeftValue = ""
    var selectedRightValue = ""
     var selectedIndex1 = 0
     var selectedIndex2 = 0
    var pickerData: [String] = [String]()
    var columnNext: [String] = [String]()
    static let sharedInstance: PickerControl = {
        let instance = PickerControl()
        return instance
    }()
    
    override init() {
        super.init()
        pickerData = ["1", "2", "3", "4", "5", "6","7","8","9","10","11","12"]
        columnNext = ["AM","PM"]
    }
    
    public func showPicker(_ titleval:String,_ style:UIAlertControllerStyle,idx1:String,idx2:String,selectedVal:@escaping (String,String)->())
    {
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: style)
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 18)
        lblTitle.textAlignment = .center
        lblTitle.text = titleval
        let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 40, width: SCREENWIDTH() - 20, height: 220))
        pickerFrame.delegate = self
        alertController.view.addSubview(lblTitle)
        alertController.view.addSubview(pickerFrame)
      
        if let foo = self.pickerData.enumerated().first(where: {$0.element == idx1})
        {
            selectedIndex1 = foo.offset
        }
        if let foo2 = self.pickerData.enumerated().first(where: {$0.element == idx2})
        {
            selectedIndex2 = foo2.offset
        }
        pickerFrame.selectRow(selectedIndex1, inComponent: 0, animated: false)
        pickerFrame.selectRow(selectedIndex2, inComponent: 1, animated: false)
        let btnOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
             selectedVal(self.selectedLeftValue,self.selectedRightValue)
        })
        
        let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(btnOk)
        alertController.addAction(btnCancel)
        
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 380)
        alertController.view.addConstraint(alertControllerHeight);
        mostTopViewController?.present(alertController, animated: true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 2
    }
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0
        {
            return pickerData.count
        }
        else
        {
            return columnNext.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
         selectedIndex1 = pickerView.selectedRow(inComponent: 0)
         selectedIndex2 = pickerView.selectedRow(inComponent: 1)
         selectedLeftValue = pickerData[selectedIndex1]
         selectedRightValue = columnNext[selectedIndex2]
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if component == 0
        {
            return pickerData[row]
        }
        else
        {
            return columnNext[row]
        }
    }
}

