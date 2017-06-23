//
//  Translucid.swift
//  Translucid
//
//  Created by Lucas Ortis on 18/12/2015.
//  Copyright © 2015 Ekhoo. All rights reserved.
//

import UIKit

open class Translucid: UIView {

    fileprivate let textLayer: CATextLayer = CATextLayer()
    fileprivate let imageLayer: CALayer = CALayer()
    
    open var backgroundLayer: CALayer = CALayer()
    
    open var text: String = "Hello World" {
        didSet {
            self.textLayer.string = self.text
            self.autoResizeTextLayer()
        }
    }

    open var backgroundImage: UIImage? {
        didSet {
            if let image = backgroundImage {
                self.imageLayer.contents = image.cgImage
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            self.backgroundLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width, height: self.bounds.size.height + 200.0)
            self.imageLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width, height: self.bounds.size.height + 200.0)
            self.textLayer.frame = self.bounds
            self.autoResizeTextLayer()
        }
    }
    
    open var font: UIFont = UIFont.boldSystemFont(ofSize: 20) {
        didSet {
            self.textLayer.font = self.font
            self.autoResizeTextLayer()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    open func animate() {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = NSValue(cgPoint: self.imageLayer.position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.imageLayer.position.x, y: self.imageLayer.position.y - 200))
        animation.duration = 15.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        self.imageLayer.add(animation, forKey: "transform")
    }
    
    fileprivate func autoResizeTextLayer() {
        var fontSize: CGFloat = 1.0
        var rect: CGRect = NSString(string: self.text).boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font.withSize(fontSize)], context: nil)
        
        while rect.size.height < self.bounds.size.height {
            fontSize += 1
            rect = NSString(string: self.text).boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font.withSize(fontSize)], context: nil)
        }
        
        fontSize -= 1
        
        self.textLayer.fontSize = fontSize
        self.textLayer.font = self.font.withSize(fontSize)
    }
    
    fileprivate func commonInit() {
        self.textLayer.string = self.text
        self.textLayer.alignmentMode = kCAAlignmentCenter
        self.textLayer.frame = self.bounds
        self.textLayer.fontSize = 0.0
        self.textLayer.font = self.font
        self.textLayer.isWrapped = true
        self.textLayer.rasterizationScale = UIScreen.main.scale
        self.textLayer.truncationMode = kCATruncationEnd
        self.textLayer.contentsScale = UIScreen.main.scale
        
        self.autoResizeTextLayer()
        
        self.layer.addSublayer(self.backgroundLayer)
//        self.layer.addSublayer(self.imageLayer)
        self.layer.mask = self.textLayer
    }
}
