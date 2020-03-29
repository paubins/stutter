
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
    lazy var timelineOffset:CGFloat =  0.0
    
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
    
    var timelinePoint:CGPoint = CGPoint.zero {
        didSet {
            timelinePoint = 20 <= timelinePoint.x ?
                (UIScreen.main.bounds.width-20 < timelinePoint.x ?
                    CGPoint(x: UIScreen.main.bounds.width-20, y: timelinePoint.y) :
                    timelinePoint) :
                CGPoint(x: 20, y: timelinePoint.y)
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
    
    var timelineRect:CGRect {
        get {
            return CGRect(x: self.timelinePoint.x - Constant.primaryControlDiameter,
                          y: self.timelinePoint.y - Constant.primaryControlDiameter,
                          width: Constant.primaryControlDiameter*2,
                          height: Constant.secondaryControlHeightFromBottom)
        }
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setStrokeColor(self.color.cgColor)
        ctx.setLineWidth(3.0)
        
        ctx.drawRadialGradient(CGGradient(colorsSpace: ctx.colorSpace,
                                          colors: [self.color.cgColor, self.color.darkerColorForColor().cgColor] as CFArray,
                                          locations: [0.0,1.0])!,
                               startCenter: CGPoint(x: self.currentPoint.x + Constant.primaryControlDiameter/2,
                                                    y: self.currentPoint.y + Constant.primaryControlDiameter/2),
                               startRadius: 0,
                               endCenter: CGPoint(x: self.currentPoint.x + Constant.primaryControlDiameter/2,
                                                  y: self.currentPoint.y + Constant.primaryControlDiameter/2),
                               endRadius: Constant.primaryControlDiameter/2,
                               options: [])
        
        ctx.setShadow(offset: CGSize(width: 2, height: 2), blur: 5)
        
        ctx.setFillColor(self.color.cgColor)

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

        ctx.addLine(to: CGPoint(x: self.timelineOffset, y: Constant.secondaryControlHeight - Constant.primaryControlDiameter/2))
        
        ctx.addCurve(to: CGPoint(x: self.timelinePoint.x, y: Constant.secondaryControlHeight),
                         control1: CGPoint(x: self.timelineOffset, y: Constant.secondaryControlHeightControlPoint1),
                         control2: CGPoint(x: self.timelineOffset, y: Constant.secondaryControlHeightControlPoint2))
        
        ctx.addLine(to: CGPoint(x: self.timelinePoint.x, y: Constant.mainControlHeight))
        
        ctx.drawPath(using: .stroke)
        
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 3)
        
        ctx.setFillColor(self.color.cgColor)
        
        ctx.addEllipse(in: CGRect(x:self.timelinePoint.x - Constant.secondaryControlDiameter/2,
                                  y: Constant.secondaryControlHeight - Constant.secondaryControlDiameter/2,
                                  width: Constant.secondaryControlDiameter,
                                  height: Constant.secondaryControlDiameter))
        
        ctx.fillEllipse(in: CGRect(x:self.timelinePoint.x - Constant.secondaryControlDiameter/2,
                                   y: Constant.secondaryControlHeight - Constant.secondaryControlDiameter/2,
                                   width: Constant.secondaryControlDiameter,
                                   height: Constant.secondaryControlDiameter))
        
        ctx.drawPath(using: .stroke)
        
    }
}
