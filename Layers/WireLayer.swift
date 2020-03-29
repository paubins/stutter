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
    
    var color:UIColor!
    
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
        
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x, y: self.currentPoint.y, width: 30, height: 30))
        ctx.setFillColor(self.color.cgColor)
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x, y: self.currentPoint.y, width: 30, height: 30))
        
        ctx.move(to: CGPoint(x: self.currentPoint.x + 15, y: self.currentPoint.y + 15))
        
        ctx.addCurve(to: CGPoint(x: self.offset, y: 100),
                         control1: CGPoint(x: self.currentPoint.x + 15, y: self.currentPoint.y + 15),
                         control2: CGPoint(x: self.offset, y: 100 - 50))
        
        ctx.addLine(to: CGPoint(x: self.offset, y: 120))
        

        
        ctx.addCurve(to: CGPoint(x: self.currentPoint.x, y: 135),
                         control1: CGPoint(x: self.offset, y: 140 + 5),
                         control2: CGPoint(x: self.offset, y: 140 + 10))
        
        ctx.addLine(to: CGPoint(x: self.currentPoint.x, y: 200))
        
        ctx.drawPath(using: .stroke)
        
        ctx.setFillColor(self.color.cgColor)
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x-5, y: 130, width: 10, height: 10))
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x-5, y: 130, width: 10, height: 10))
        
        ctx.drawPath(using: .stroke)
        
    }
}
