
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
    
    var currentPoint:CGPoint = CGPoint.zero {
        didSet {
            currentPoint = Constant.mainControllCutoffMin <= currentPoint.y ?
                CGPoint(x: currentPoint.x, y: Constant.mainControllCutoffMin) :
                (currentPoint.y <= Constant.mainControllCutoffMax ?
                    CGPoint(x: currentPoint.x, y: Constant.mainControllCutoffMax) : currentPoint)
        }
    }
    
    var currentRect:CGRect {
        get {
            return CGRect(x: self.currentPoint.x - Constant.primaryControlDiameter,
                          y: self.currentPoint.y - Constant.primaryControlDiameter,
                          width: Constant.primaryControlDiameter*2,
                          height: Constant.primaryControlDiameter*2)
        }
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setStrokeColor(self.color.cgColor)
        ctx.setLineWidth(3.0)
        
        ctx.setShadow(offset: CGSize(width: 2, height: 2), blur: 5)
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x,
                                  y: self.currentPoint.y,
                                  width: Constant.primaryControlDiameter,
                                  height: Constant.primaryControlDiameter))
        
        ctx.setFillColor(self.color.cgColor)
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x,
                                   y: self.currentPoint.y,
                                   width: Constant.primaryControlDiameter,
                                   height: Constant.primaryControlDiameter))
        
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
        
        ctx.move(to: CGPoint(x: self.currentPoint.x + Constant.primaryControlDiameter/2,
                             y: self.currentPoint.y + Constant.primaryControlDiameter/2))
        
        if (self.selected) {
            ctx.setLineDash(phase: 0, lengths: [6,10])
        }
        
        ctx.addCurve(to: CGPoint(x: self.offset, y: Constant.secondaryControlHeight - 20),
                         control1: CGPoint(x: self.currentPoint.x + Constant.primaryControlDiameter/2,
                                           y: self.currentPoint.y + Constant.primaryControlDiameter/2),
                         control2: CGPoint(x: self.offset, y: Constant.secondaryControlHeight - 100))

        ctx.addLine(to: CGPoint(x: self.offset, y: Constant.secondaryControlHeight - Constant.primaryControlDiameter/2))
        
        ctx.addCurve(to: CGPoint(x: self.currentPoint.x, y: Constant.secondaryControlHeight),
                         control1: CGPoint(x: self.offset, y: Constant.secondaryControlHeightControlPoint1),
                         control2: CGPoint(x: self.offset, y: Constant.secondaryControlHeightControlPoint2))
        
        ctx.addLine(to: CGPoint(x: self.currentPoint.x, y: Constant.mainControlHeight))
        
        ctx.drawPath(using: .stroke)
        
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 3)
        
        ctx.setFillColor(self.color.cgColor)
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x - Constant.secondaryControlDiameter/2,
                                  y: Constant.secondaryControlHeight - Constant.secondaryControlDiameter/2,
                                  width: Constant.secondaryControlDiameter,
                                  height: Constant.secondaryControlDiameter))
        
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x - Constant.secondaryControlDiameter/2,
                                   y: Constant.secondaryControlHeight - Constant.secondaryControlDiameter/2,
                                   width: Constant.secondaryControlDiameter,
                                   height: Constant.secondaryControlDiameter))
        
        ctx.drawPath(using: .stroke)
        
    }
}
