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
    
    var previousScreenWidth:CGFloat = UIScreen.main.bounds.width
    var currentLayerIndex:Int = 0
    var shouldRedraw:Bool = false
    
    var count:CGFloat = 0
    var initial:Bool = true
    
    init(frame: CGRect, count: Int) {
        super.init(frame: frame)
        
        self.count = CGFloat(count)
        
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panned))
        self.addGestureRecognizer(self.gestureRecognizer)
        
        let layer:WireLayer = WireLayer()
        layer.frame = self.bounds
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        
        layer.color = Constant.COLORS[0]
        layer.currentPoint =  CGPoint(x: 10, y: Int(UIScreen.main.bounds.size.height))
        layer.offset = UIScreen.main.bounds.size.width/self.count/2
        
        self.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        
        for i in 1..<Int(self.count) {
            let layer:WireLayer = WireLayer()
            layer.color = Constant.COLORS[i]
            layer.frame = self.bounds
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.contentsScale = UIScreen.main.scale
            
            layer.currentPoint = CGPoint(x: Int(UIScreen.main.bounds.size.width/self.count * CGFloat(i)),
                                         y: Int(UIScreen.main.bounds.size.height))
            layer.offset = UIScreen.main.bounds.size.width/self.count * CGFloat(i) + UIScreen.main.bounds.size.width/self.count/2
            
            self.layer.addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (i, layer) in self.layer.sublayers!.enumerated() {
            (layer as! WireLayer).frame = self.bounds
            
            if !self.initial {
                (layer as! WireLayer).currentPoint = CGPoint(x: Int(UIScreen.main.bounds.size.width*self.getPercentageX(index: i)),
                                                             y: Int((UIScreen.main.bounds.size.height)*self.getPercentageY(index: i)))
            }
            
            (layer as! WireLayer).offset = UIScreen.main.bounds.size.width/self.count * CGFloat(i) + UIScreen.main.bounds.size.width/self.count/2
            
            (layer as! WireLayer).setNeedsDisplay()
        }
        
        self.initial = false
        self.previousScreenWidth = UIScreen.main.bounds.size.width
    }
    
    func animate() {
        for (i, layer) in self.layer.sublayers!.enumerated() {
            let animation = CABasicAnimation(keyPath: "v1x")
            animation.duration = 10
            
            // Your new shape here
            animation.toValue = 20
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            (layer as! WireLayer).add(animation, forKey: "v1x")
            
            let animation2 = CABasicAnimation(keyPath: "v1y")
            animation2.duration = 10
            
            // Your new shape here
            animation2.toValue = 20
            animation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            (layer as! WireLayer).add(animation2, forKey: "v1y")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPercentageX(index: Int) -> CGFloat {
        let layer:WireLayer = self.layer.sublayers![index] as! WireLayer
        return layer.currentPoint.x / self.previousScreenWidth
    }
    
    func getPercentageY(index: Int) -> CGFloat {
        let layer:WireLayer = self.layer.sublayers![index] as! WireLayer
        if let window = UIApplication.shared.keyWindow {
            return (UIScreen.main.bounds.height-self.superview!.convert(layer.currentPoint, to: window).y)/UIScreen.main.bounds.height
        }
        
        return layer.currentPoint.y/UIScreen.main.bounds.height
    }
    
    @objc func panned(gestureRecognizer: UIPanGestureRecognizer) {
        let point:CGPoint = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            for (i, wireLayer) in (self.layer.sublayers?.enumerated())! {
                if (wireLayer as! WireLayer).currentRect.contains(point) {
                    self.currentLayerIndex = i
                    self.shouldRedraw = true
                    (wireLayer as! WireLayer).selected = true
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
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).selected = false
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()
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
    
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if (event == "contents") {
            return nil
        }
        
        return super.action(for: layer, forKey: event)
    }
}
