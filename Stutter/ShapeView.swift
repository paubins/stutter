//
//  ShapeView.swift
//  TestCGPath
//
//  Created by Patrick Aubin on 10/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Foundation
import UIKit

protocol ShapeViewDelegate {
    func slidingHasBegun()
    func percentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat)
    func slidingHasEnded()
}

class ShapeView : UIView {
    
    var delegate:ShapeViewDelegate!
    
    var gestureRecognizer:UIPanGestureRecognizer!
    
    var currentLayerIndex:Int = 0
    var shouldRedraw:Bool = false
    
    var count:CGFloat = 0
    
    init(frame: CGRect, count: Int) {
        super.init(frame: frame)
        
        self.count = CGFloat(count)
        
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panned))
        self.addGestureRecognizer(self.gestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layer:WireLayer = WireLayer()
        layer.frame = self.bounds
        layer.currentPoint = CGPoint(x: 100, y: 100)
        layer.offset = UIScreen.main.bounds.size.width/5/2
        self.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        
        for i in 1..<Int(self.count) {
            let layer:WireLayer = WireLayer()
            
            layer.frame = self.bounds
            layer.currentPoint = CGPoint(x: Int(UIScreen.main.bounds.size.width/self.count * CGFloat(i)), y: 0)
            layer.offset = UIScreen.main.bounds.size.width/self.count * CGFloat(i) + UIScreen.main.bounds.size.width/self.count/2
            
            self.layer.addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func panned(gestureRecognizer: UIPanGestureRecognizer) {
        let point:CGPoint = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            for (i, wireLayer) in (self.layer.sublayers?.enumerated())! {
                if (wireLayer as! WireLayer).currentRect.contains(point) {
                    self.currentLayerIndex = i
                    self.shouldRedraw = true
                    self.delegate.slidingHasBegun()
                    break
                } else {
                    print("nah")
                }
            }
            
        case .changed:
            if self.shouldRedraw {
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).currentPoint = point
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()

                if (self.delegate != nil) {
                    self.delegate.percentageOfWidth(index: self.currentLayerIndex,
                                                    percentageX: point.x/UIScreen.main.bounds.width,
                                                    percentageY: point.y/UIScreen.main.bounds.height)
                }
            }
            
        case .ended:
            if self.shouldRedraw {
                self.delegate.slidingHasEnded()
                self.shouldRedraw = false
                self.currentLayerIndex = 0
            }
            break
        case .cancelled:
            self.shouldRedraw = false
            break
        case .failed:
            self.shouldRedraw = false
            break
            
        default:
            print("no bueno")
        }
        
    }
}
