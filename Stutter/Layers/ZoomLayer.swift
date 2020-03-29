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
        
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1)
        
        ctx.move(to: CGPoint(x: 0, y: 25))
        ctx.addLine(to: CGPoint(x: 12, y: 25))
        
        ctx.move(to: CGPoint(x: 0, y: 50))
        ctx.addLine(to: CGPoint(x: 6, y: 50))

        ctx.move(to: CGPoint(x: 0, y: 75))
        ctx.addLine(to: CGPoint(x: 12, y: 75))
        
        ctx.move(to: CGPoint(x: 0, y: 100))
        ctx.addLine(to: CGPoint(x: 6, y: 100))

        ctx.move(to: CGPoint(x: 0, y: 125))
        ctx.addLine(to: CGPoint(x: 12, y: 125))
        
        ctx.move(to: CGPoint(x: 0, y: 150))
        ctx.addLine(to: CGPoint(x: 6, y: 150))

        ctx.move(to: CGPoint(x: 0, y: 175))
        ctx.addLine(to: CGPoint(x: 12, y: 175))
 
        ctx.move(to: CGPoint(x: 0, y: 200))
        ctx.addLine(to: CGPoint(x: 6, y: 200))
        
        ctx.move(to: CGPoint(x: 0, y: 225))
        ctx.addLine(to: CGPoint(x: 12, y: 225))
        
        ctx.move(to: CGPoint(x: 36, y: 225))
        ctx.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - 25, y: 225))
        
        ctx.move(to: CGPoint(x: UIScreen.main.bounds.width/2 - 10, y: 225))
        ctx.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + 10, y: 225))
        
        ctx.move(to: CGPoint(x: UIScreen.main.bounds.width/2 + 25, y: 225))
        ctx.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + 25 + UIScreen.main.bounds.width/2 - 58, y: 225))

        ctx.drawPath(using: .stroke)
    }
}
