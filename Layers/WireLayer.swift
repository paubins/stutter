//
//  WireLayer.swift
//  TestCGPath
//
//  Created by Patrick Aubin on 10/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Foundation
import UIKit

class WireLayer : CALayer {
    
    lazy var offset:CGFloat =  0.0
    var selected:Bool = false
    
    var v1x : CGFloat = 0.0
    var v1y : CGFloat = 0.0
    
    var color:UIColor = UIColor.orange
    
    var currentPoint:CGPoint = CGPoint(x: 15, y: 15) {
        didSet {
            currentPoint = 40 < currentPoint.y ? CGPoint(x: currentPoint.x, y: 40) : (currentPoint.y < 5 ? CGPoint(x: currentPoint.x, y: 5) : currentPoint)
        }
    }
    
    var currentRect:CGRect {
        get {
            return CGRect(x: self.currentPoint.x - 30, y: self.currentPoint.y - 30, width: 60, height: 60)
        }
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setStrokeColor(self.color.cgColor)
        ctx.setLineWidth(3.0);
        ctx.setShadow(offset: CGSize(width: 2, height: 2), blur: 5)
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x + self.v1x, y: self.currentPoint.y + self.v1y, width: 30, height: 30))
        ctx.setFillColor(self.color.cgColor)
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x + self.v1x, y: self.currentPoint.y + self.v1y, width: 30, height: 30))
        
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
        
        ctx.move(to: CGPoint(x: self.currentPoint.x + 15 + self.v1x, y: self.currentPoint.y + 15 + self.v1y))
        
        if (self.selected) {
            ctx.setLineDash(phase: 0, lengths: [6,10])
        }
        
        ctx.addCurve(to: CGPoint(x: self.offset, y: 100),
                         control1: CGPoint(x: self.currentPoint.x + 15, y: self.currentPoint.y + 15),
                         control2: CGPoint(x: self.offset, y: 100 - 50))

        ctx.addLine(to: CGPoint(x: self.offset, y: 120))
        
        ctx.addCurve(to: CGPoint(x: self.currentPoint.x, y: 135),
                         control1: CGPoint(x: self.offset, y: 140 + 5),
                         control2: CGPoint(x: self.offset, y: 140 + 10))
        
        ctx.addLine(to: CGPoint(x: self.currentPoint.x, y: 200))
        
        ctx.drawPath(using: .stroke)
        
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 3)
        
        ctx.setFillColor(self.color.cgColor)
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x-5, y: 130, width: 10, height: 10))
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x-5, y: 130, width: 10, height: 10))
        
        ctx.drawPath(using: .stroke)
        
    }
    
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(v1x) || key == #keyPath(v1y) {
            return true
        }
        return super.needsDisplay(forKey:key)
    }
    
    override func action(forKey key: String) -> CAAction? {
        if self.presentation() != nil {
            if key == #keyPath(v1x) || key == #keyPath(v1y) {
                let ba = CABasicAnimation(keyPath: key)
                ba.fromValue = self.presentation()!.value(forKey:key)
                return ba
            }
        }
        return super.action(forKey: key)
    }
}
