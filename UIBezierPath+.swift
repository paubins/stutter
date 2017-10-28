//
//  UIBezierPath+.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/27/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

@objc extension UIBezierPath {
    func shake(layer: CALayer) {
        let positionAnimation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        
        positionAnimation.path = self.cgPath
        positionAnimation.duration = 1.0
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        CATransaction.begin()
        layer.add(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
}
