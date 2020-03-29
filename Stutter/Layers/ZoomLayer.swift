//
//  ZoomLayer.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/6/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class ZoomLayer : CALayer {
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        ctx.setStrokeColor(UIColor.clear.cgColor)
        ctx.setLineWidth(2)
        
        ctx.move(to: CGPoint(x: 0, y: 2))
        ctx.addLine(to: CGPoint(x: 25, y: 25))
        
//        ctx.move(to: CGPoint(x: 0, y: 50))
        ctx.addLine(to: CGPoint(x: 0, y: 50))
        ctx.addLine(to: CGPoint(x: 25, y: 75))

//        ctx.move(to: CGPoint(x: 0, y: 100))
        ctx.addLine(to: CGPoint(x: 0, y: 100))
        ctx.addLine(to: CGPoint(x: 25, y: 125))
        
//        ctx.move(to: CGPoint(x: 0, y: 150))
        ctx.addLine(to: CGPoint(x: 0, y: 150))
        ctx.addLine(to: CGPoint(x: 25, y: 175))
        
//        ctx.move(to: CGPoint(x: 0, y: 200))
        ctx.addLine(to: CGPoint(x: 0, y: 200))
        ctx.addLine(to: CGPoint(x: 25, y: 225))
        
//        ctx.move(to: CGPoint(x: 0, y: 250))
        ctx.addLine(to: CGPoint(x: 0, y: 250))
        
        ctx.drawPath(using: .stroke)
    }
}
