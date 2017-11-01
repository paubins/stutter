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
    
    var currentPoint:CGPoint = CGPoint(x: 15, y: 15) {
        didSet {
            currentPoint = 110 < currentPoint.y ? CGPoint(x: currentPoint.x, y: 110) : currentPoint
        }
    }
    
    var currentRect:CGRect {
        get {
            return CGRect(x: self.currentPoint.x - 30, y: self.currentPoint.y - 30, width: 60, height: 60)
        }
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setStrokeColor(UIColor.blue.cgColor)
        ctx.setLineWidth(3.0);
        
        ctx.addEllipse(in: CGRect(x:self.currentPoint.x, y: self.currentPoint.y, width: 30, height: 30))
        ctx.fillEllipse(in: CGRect(x:self.currentPoint.x, y: self.currentPoint.y, width: 30, height: 30))
        
        ctx.move(to: CGPoint(x: self.currentPoint.x + 15, y: self.currentPoint.y + 15))
        
        ctx.addCurve(to: CGPoint(x: self.offset, y: 200),
                         control1: CGPoint(x: self.currentPoint.x + 15, y: self.currentPoint.y + 15),
                         control2: CGPoint(x: self.offset, y: 200 - 100))
        
        ctx.addLine(to: CGPoint(x: self.offset, y: 220))
        
        ctx.addCurve(to: CGPoint(x: self.currentPoint.x, y: 240),
                         control1: CGPoint(x: self.offset, y: 230 + 5),
                         control2: CGPoint(x: self.offset, y: 230 + 10))
        
        ctx.addLine(to: CGPoint(x: self.currentPoint.x, y: 300))
        
        ctx.drawPath(using: .stroke)
    }
}
