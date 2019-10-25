//
//  ImageOptionsView.swift
//  ImagePicker
//
//  Created by Arjav Lad on 02/01/18.
//  Copyright © 2018 Arjav Lad. All rights reserved.
//

import UIKit

protocol ImageOptionsViewDelegate {
    func choosefacebook()
    func chooseInstagram()
    func chooseDevicePhotoLibrary()
}

class ImageOptionsView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var viewStack: UIStackView!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnDevicePhotoLibrary: UIButton!

    var delegate: ImageOptionsViewDelegate?

    init(withDelegate: ImageOptionsViewDelegate) {
        self.delegate = withDelegate
        super.init(frame: CGRect.init(x: 0, y: 0, width: 375, height: 386))
        self.nibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }

    private func nibSetup() {
        self.backgroundColor = .clear
        Bundle.main.loadNibNamed("ImageOptionsView", owner: self, options: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.containerView)
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.containerView]))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.containerView]))
        self.layoutIfNeeded()
    }

    @IBAction func onFacebookTap(_ sender: UIButton) {
        self.delegate?.choosefacebook()
    }

    @IBAction func onDevicePhotoLibraryTap(_ sender: UIButton) {
        self.delegate?.chooseDevicePhotoLibrary()
    }

    @IBAction func onInstagramTap(_ sender: UIButton) {
        self.delegate?.chooseInstagram()
    }
}
