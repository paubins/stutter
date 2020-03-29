//
//  LinearProgressView.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/7/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LinearProgressBar: UIView {
    
    
    @IBInspectable var barColor: UIColor = .green
    @IBInspectable var trackColor: UIColor = .yellow
    @IBInspectable var barThickness: CGFloat = 10
    @IBInspectable var barPadding: CGFloat = 0
    @IBInspectable var trackPadding: CGFloat = 6
    @IBInspectable var progressValue: CGFloat = 0 {
        didSet {
            if (progressValue >= 100) {
                progressValue = 100
            } else if (progressValue <= 0) {
                progressValue = 0
            }
            setNeedsDisplay()
        }
    }
    
    private var trackHeight: CGFloat {
        return barThickness + trackPadding
    }
    
    private var trackOffset: CGFloat {
        return trackHeight / 2
    }
    
    override func draw(_ rect: CGRect) {
        drawProgressView()
    }
    
    // Draws the progress bar and track
    func drawProgressView() {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.saveGState()
            
            let height = frame.height / 2
            
            /* Progres Bar Track */
            ctx.setStrokeColor(trackColor.cgColor)
            ctx.beginPath()
            ctx.setLineWidth(trackHeight)
            ctx.move(to: CGPoint(x: barPadding + trackOffset, y: height))
            ctx.addLine(to: CGPoint(x: frame.width - barPadding - trackOffset, y: height))
            ctx.setLineCap(CGLineCap.round)
            ctx.strokePath()
            
            
            /* Progress Bar */
            
            ctx.setStrokeColor(barColor.cgColor)
            ctx.setLineWidth(barThickness)
            ctx.beginPath()
            ctx.move(to: CGPoint(x: barPadding + trackOffset, y: height ))
            ctx.addLine(to: CGPoint(x: barPadding + trackOffset + calcualtePercentage(), y: height))
            ctx.setLineCap(CGLineCap.round)
            ctx.strokePath()
        }
    }
    
    /**
     Calculates the percent value of the progress bar
     
     - returns: The percentage of progress
     */
    func calcualtePercentage() -> CGFloat {
        let screenWidth = frame.size.width - (barPadding * 2) - (trackOffset * 2)
        let progress = ((progressValue / 100) * screenWidth)
        return progress < 0 ? barPadding : progress
    }
}
