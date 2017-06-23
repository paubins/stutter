//
//  SDevCircleButton.swift
//  SDevCircleButtonSwift
//
//  Created by Sedat ÇİFTÇİ on 15/10/14.
//  Copyright (c) 2014 Sedat ÇİFTÇİ. All rights reserved.
//

import UIKit
import QuartzCore

let SDevCircleButtonBorderWidth : CGFloat = 3.0


class SDevCircleButton: UIButton {
    var borderColor: UIColor! {
        didSet(newValue) {
            self.borderColor = newValue
            self.layoutSubviews()
        }
    }
    
    override var highlighted: Bool {
        willSet(newValue) {
            if highlighted {
                self.layer.borderColor = self.borderColor.colorWithAlphaComponent(1).CGColor
                self.triggerAnimateTap()
            } else {
                self.layer.borderColor = self.borderColor.colorWithAlphaComponent(0.7).CGColor
            }
        }
    }
    var animateTap: Bool!
    var displayShading: Bool?
    var borderSize: CGFloat!
    
    var highLightView: UIView!
    var gradientLayerTop: CAGradientLayer!
    var gradientLayerBottom: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        highLightView = UIView(frame: frame)
        highLightView.alpha = 0
        highLightView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        borderColor = UIColor.whiteColor()
        animateTap = true
        borderSize = SDevCircleButtonBorderWidth
        
        self.clipsToBounds = true
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        gradientLayerTop = CAGradientLayer()
        gradientLayerTop.frame = CGRectMake(0, 0, frame.size.width, frame.size.height / 4)
        gradientLayerTop.colors = [UIColor.blackColor().CGColor as AnyObject!,UIColor.blackColor().colorWithAlphaComponent(0.01).CGColor as AnyObject!]
        
        
        gradientLayerBottom = CAGradientLayer()
        gradientLayerBottom.frame = CGRectMake(0, frame.size.height * 3 / 4, frame.size.width, frame.size.height / 4)
        gradientLayerBottom.colors = [UIColor.lightGrayColor().colorWithAlphaComponent(0.01).CGColor as AnyObject!, UIColor.blackColor().CGColor as AnyObject!]
        
        self.addSubview(highLightView)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDisplayShading(displayShading: Bool) -> Void {
        self.displayShading = displayShading
        
        if displayShading {
            self.layer.addSublayer(self.gradientLayerTop)
            self.layer.addSublayer(self.gradientLayerBottom)
        } else {
            self.gradientLayerTop.removeFromSuperlayer()
            self.gradientLayerBottom.removeFromSuperlayer()
        }
        
        self.layoutSubviews()
    }
    
    override func layoutSubviews() -> Void {
        super.layoutSubviews()
        self.updateMaskToBounds(self.bounds)
    }
    

    func updateMaskToBounds(maskBounds: CGRect) -> Void {
        let maskLayer: CAShapeLayer = CAShapeLayer()
        let maskPath: CGPathRef = CGPathCreateWithEllipseInRect(maskBounds, nil)
        
        maskLayer.bounds = maskBounds
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.blackColor().CGColor
        
        let point : CGPoint = CGPointMake(maskBounds.size.width / 2, maskBounds.size.height / 2)
        maskLayer.position = point
        
        self.layer.mask = maskLayer
        
        self.layer.cornerRadius = CGRectGetHeight(maskBounds) / 2.0
        self.layer.borderColor = self.borderColor .colorWithAlphaComponent(0.7).CGColor
        self.layer.borderWidth = self.borderSize
        
        self.highLightView.frame = self.bounds
        
    }
    
    func blink() -> Void {
        let pathFrame: CGRect = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height)
        let path: UIBezierPath = UIBezierPath(roundedRect: pathFrame, cornerRadius: self.layer.cornerRadius)
        
        let shapePosition: CGPoint = self.superview!.convertPoint(self.center, fromView: self.superview)
        
        let circleShape: CAShapeLayer = CAShapeLayer()
        circleShape.path = path.CGPath
        circleShape.position = shapePosition
        circleShape.fillColor = UIColor.clearColor().CGColor
        circleShape.opacity = 0
        circleShape.strokeColor = self.borderColor.CGColor
        circleShape.lineWidth = 2.0
        
        self.superview!.layer.addSublayer(circleShape)
        
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(2.0, 2.0, 1))
        
        let alphaAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let animation: CAAnimationGroup = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.7
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        circleShape.addAnimation(animation, forKey: nil)
        
    }
    
    func triggerAnimateTap() -> Void {
        if self.animateTap == false {
            return
        }
        
        self.highLightView.alpha = 1
        
        let this: SDevCircleButton = self
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            this.highLightView.alpha = 0.0
            }, completion: nil)
        
        let pathFrame: CGRect = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height)
        let path: UIBezierPath = UIBezierPath(roundedRect: pathFrame, cornerRadius: self.layer.cornerRadius)
        
        let shapePosition: CGPoint = self.superview!.convertPoint(self.center, fromView: self.superview)
        
        let circleShape: CAShapeLayer = CAShapeLayer()
        circleShape.path = path.CGPath
        circleShape.position = shapePosition
        circleShape.fillColor = UIColor.clearColor().CGColor
        circleShape.opacity = 0
        circleShape.strokeColor = self.borderColor.CGColor
        circleShape.lineWidth = 2.0
        
        self.superview?.layer.addSublayer(circleShape)
        
        
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(2.5, 2.5, 1))
        
        let alphaAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let animation: CAAnimationGroup = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.7
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        circleShape.addAnimation(animation, forKey: nil)

        
    }
    
    func setImage(image: UIImage!, animated: Bool) -> Void {
        super.setImage(nil, forState: UIControlState.Normal)
        super.setImage(image, forState: UIControlState.Selected)
        super.setImage(image, forState: UIControlState.Highlighted)
        
        if animated {
            let tmpImageView : UIImageView = UIImageView(frame: self.bounds)
            
            tmpImageView.image = image
            tmpImageView.alpha = 0
            tmpImageView.backgroundColor = UIColor.clearColor()
            tmpImageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.addSubview(tmpImageView)
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                tmpImageView.alpha = 1
                }, completion: { (finished) -> Void in
                    self.setImage(image, tmpImageView: tmpImageView)
            })
        } else {
            super.setImage(image, forState: UIControlState.Normal)
        }
        
    }
    
    
    func setImage(image: UIImage, tmpImageView : UIImageView) -> Void {
        super.setImage(image, forState: UIControlState.Normal)
        tmpImageView.removeFromSuperview()
    }
    
}
