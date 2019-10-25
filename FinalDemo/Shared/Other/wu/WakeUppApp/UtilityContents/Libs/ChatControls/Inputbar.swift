//
//  Inputbar.swift
//
//  Created by Payal Umraliya
//  Copyright (c) 2017 Payal Umraliya. All rights reserved.
//

import UIKit

let RIGHT_BUTTON_SIZE:CGFloat = 50
let LEFT_BUTTON_SIZE:CGFloat = 45


@objc protocol InputbarDelegate:NSObjectProtocol {
    func inputbarDidPressRightButton(inputbar:Inputbar)
    func inputbarDidPressLeftButton(inputbar:Inputbar)
    func inputbarDidPressLeft2Button(inputbar:Inputbar)
    @objc optional func inputbarDidPressVoiceButton(inputbar:Inputbar)
    @objc optional func inputbarDidChangeHeight(newHeight:CGFloat)
    @objc optional func inputbarDidBecomeFirstResponder(inputbar:Inputbar)
    @objc optional func inputBarTextDidChange(inputbar:Inputbar)
}

class Inputbar: UIToolbar, HPGrowingTextViewDelegate {
    
    var inputDelegate:InputbarDelegate!
    var textView:HPGrowingTextView!
    var rightButton:UIButton!
    var leftButton:UIButton!
    var leftButton1:UIButton!
    
    var placeholder:String! {
        didSet {
            self.textView.placeholder = self.placeholder
        }
    }
    
    var leftButtonImage:UIImage! {
        didSet {
            self.leftButton?.setImage(self.leftButtonImage, for:.normal)
        }
    }
    var rightButtonImage:UIImage! {
        didSet {
            self.rightButton?.setImage(self.rightButtonImage, for:.normal)
        }
    }
    var leftButtonImage1:UIImage! {
        didSet {
            self.leftButton1?.setImage(self.leftButtonImage1, for:.normal)
        }
    }
    var rightButtonTextColor:UIColor! {
        didSet {
            self.rightButton?.setTitleColor(self.rightButtonTextColor, for:.normal)
        }
    }
    var rightButtonText:String! {
        didSet {
            self.rightButton?.setTitle(self.rightButtonText, for:.normal)
        }
    }
    
    
    var text:String {
        return self.textView.text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addContent()
    }
    
    func addContent()
    {
        self.addTextView()
        self.addRightButton()
        self.addLeftButton()
        self.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    func addTextView()
    {
        self.clipsToBounds = true
        let size = self.frame.size
        if self.tag == 111
        {
            self.textView = HPGrowingTextView(frame:CGRect(x:LEFT_BUTTON_SIZE,
                                                       y:5,
                                                       width:size.width - LEFT_BUTTON_SIZE - RIGHT_BUTTON_SIZE,
                                                       height:size.height))
        }
        else
        {
            self.textView = HPGrowingTextView(frame:CGRect(x:5,
                                                           y:5,
                                                           width:size.width - RIGHT_BUTTON_SIZE,
                                                           height:size.height))
        }
        self.textView.isScrollable = false
        self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        
        self.textView.minNumberOfLines = 1
        self.textView.maxNumberOfLines = 6
        self.textView.returnKeyType = .go
        self.textView.font = UIFont.systemFont(ofSize: 15)
        self.textView.delegate = self
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        self.textView.backgroundColor = UIColor.white
        self.textView.placeholder = self.placeholder
//
        self.textView.tintColor = UIColor.black
        //self.textView.autocapitalizationType = .Sentences
        self.textView.keyboardType = .default
        self.textView.returnKeyType = .default
        self.textView.enablesReturnKeyAutomatically = true
        //self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        //self.textView.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 0)
//        self.textView.layer.cornerRadius = 5
//        self.textView.layer.borderWidth = 0.5
//        self.textView.layer.borderColor =  UIColor(red:200/255 ,green:200/255, blue:205/255, alpha:1).cgColor
        
        self.textView.autoresizingMask = .flexibleWidth;
        self.backgroundColor = UIColor.clear
        // view hierachy
        self.addSubview(self.textView)
    }
    
    func addRightButton() {
        let size = self.frame.size
        
        self.rightButton = UIButton()
        self.rightButton.frame = CGRect(x:size.width - RIGHT_BUTTON_SIZE,y: 0, width:RIGHT_BUTTON_SIZE,height: size.height)
        self.rightButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        self.rightButton.setTitleColor(UIColor.blue, for:.normal)
        self.rightButton.setTitleColor(UIColor.lightGray, for:.selected)
        self.rightButton.setTitle("", for:.normal)
         self.rightButton.setImage(self.rightButtonImage, for:.normal)
        //self.rightButton.setImage(UIImage.init(named: "voice_msg"), for: .normal)
        self.rightButton.addTarget(self, action: #selector(Inputbar.didPressRightButton(sender:)), for:.touchUpInside)
        
        self.addSubview(self.rightButton)
        self.rightButton.backgroundColor = UIColor.clear
        self.rightButton.isSelected = true
    }
    
    func addLeftButton()
    {
        let size = self.frame.size
        self.leftButton = UIButton()
        self.leftButton.frame = CGRect(x:0,y: 0,width: LEFT_BUTTON_SIZE,height: size.height)
       
        self.leftButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.leftButton.setImage(self.leftButtonImage, for:.normal)
        self.leftButton.addTarget(self, action:#selector(Inputbar.didPressLeftButton(sender:)), for:.touchUpInside)
//        self.leftButton1 = UIButton()
//        self.leftButton1.frame = CGRect(x:LEFT_BUTTON_SIZE,y: 0,width: LEFT_BUTTON_SIZE,height: size.height)
//        self.leftButton1.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
//        self.leftButton1.setImage(self.leftButtonImage, for:.normal)
        self.leftButton.backgroundColor = UIColor.clear
//        self.leftButton1.backgroundColor = UIColor.clear
//        self.leftButton1.addTarget(self, action:#selector(Inputbar.didPressLeft2Button(sender:)), for:.touchUpInside)
        self.addSubview(self.leftButton)
      //  self.addSubview(self.leftButton1)
    }
    
    func inputResignFirstResponder() {
        self.textView.resignFirstResponder()
    }
    
    
    // MARK - Delegate
    
    @objc func didPressRightButton(sender:UIButton) {
        
        if isDNDActive == true{
            return
        }
        
        if self.rightButton.isSelected {
            if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputbarDidPressVoiceButton(inputbar:))) {
                self.inputDelegate.inputbarDidPressVoiceButton!(inputbar: self)
            }
        }
        else{
            self.inputDelegate?.inputbarDidPressRightButton(inputbar: self)
            self.textView.text = ""
        }
        
    }
    
    @objc func didPressLeftButton(sender:UIButton) {
        self.inputDelegate?.inputbarDidPressLeftButton(inputbar: self)
    }
    @objc func didPressLeft2Button(sender:UIButton) {
        self.inputDelegate?.inputbarDidPressLeft2Button(inputbar: self)
    }
    // MARK - HPGrowingTextView
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let diff = growingTextView.frame.size.height - CGFloat(height)
        
        var r = self.frame
        r.size.height -= diff
        r.origin.y += diff
        self.frame = r
        
        if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputbarDidChangeHeight(newHeight:))) {
            self.inputDelegate.inputbarDidChangeHeight!(newHeight: self.frame.size.height)
        }
    }
    
    func growingTextViewDidBeginEditing(_ growingTextView: HPGrowingTextView!) {
        if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputbarDidBecomeFirstResponder(inputbar:))) {
            self.inputDelegate.inputbarDidBecomeFirstResponder!(inputbar: self)
        }
    }
    
    
    func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        let text = growingTextView.text.replacingOccurrences(of: " ", with:"")
        if placeholder.contains("Write")
        {
            if placeholder.contains("caption")
            {
                self.rightButton.isSelected = true
            }
            else
            {
                self.rightButton.isSelected = false
            }
            
            //self.rightButton.isSelected = false
            self.rightButton.setImage(UIImage(named:"send_btn"), for: .normal)
        }
        else
        {
            if text.count == 0 {
                self.rightButton.isSelected = true
                self.rightButton.setImage(UIImage(named:"voice_msg"), for: .normal)
            }
            else {
                self.rightButton.isSelected = false
                self.rightButton.setImage(UIImage(named:"send_btn"), for: .normal)
            }
        }
        
        if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputBarTextDidChange(inputbar:))) {
            self.inputDelegate.inputBarTextDidChange!(inputbar: self)
        }
        
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        if text == "\n" {
            let enterKeyIsSend = UserDefaultManager.getBooleanFromUserDefaults(key: kEnterKeyIsSend)
            if enterKeyIsSend{
                didPressRightButton(sender: rightButton)
                return false
            }
        }
        return true
    }
    
}
