//
//  RPLoadingAnimationView.swift
//  RPLoadingAnimation
//
//  Created by naoyashiga on 2015/10/11.
//  Copyright © 2015年 naoyashiga. All rights reserved.
//

import UIKit
protocol RPLoadingAnimationDelegate: class {
    func setup(_ layer: CALayer, size: CGSize, colors: [UIColor])
}
public enum RPLoadingAnimationType {
    case rotatingCircle
}

class AnimationFactory {
    class func animationForType(_ type: RPLoadingAnimationType) -> RPLoadingAnimationDelegate {
        switch type {
        case .rotatingCircle:
            return RotatingCircle()
        }
    }
}

open class RPLoadingAnimationView: UIView {
    fileprivate static let defaultType = RPLoadingAnimationType.rotatingCircle
    fileprivate static let defaultColors = [UIColor.black]
    fileprivate static let defaultSize = CGSize(width: 40, height: 40)
    
    fileprivate var type: RPLoadingAnimationType
    fileprivate var colors: [UIColor]
    fileprivate var size1: CGSize
    
    required public init?(coder aDecoder: NSCoder) {
        self.type = RPLoadingAnimationView.defaultType
        self.colors = RPLoadingAnimationView.defaultColors
        self.size1 = RPLoadingAnimationView.defaultSize
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, type: RPLoadingAnimationType = defaultType, colors: [UIColor] = defaultColors, size: CGSize = defaultSize) {
        self.type = type
        self.colors = colors
        self.size1 = size
        super.init(frame: frame)
    }
    
    func setupAnimation() {
        let animation = AnimationFactory.animationForType(type)
        layer.sublayers = nil
        animation.setup(layer, size: size1, colors: colors)
    }
}
