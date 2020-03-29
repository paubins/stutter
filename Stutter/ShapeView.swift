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
    func slidingHasBegun(point: CGPoint)
    func percentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint)
    func slidingHasEnded(point: CGPoint)
    func tapped()
    
    func timelineScrubbingHasBegun(point: CGPoint)
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint)
    func timelineScrubbingHasEnded(point: CGPoint)
}

class ShapeView : UIView {
    
    var delegate:ShapeViewDelegate!
    
    var gestureRecognizer:UIPanGestureRecognizer!
    var touchGestureRecognizer:UITapGestureRecognizer!
    
    var previousScreenWidth:CGFloat = UIScreen.main.bounds.width
    var currentLayerIndex:Int = 0
    var shouldRedraw:Bool = false
    var shouldRedrawTimeline:Bool = false
    
    var count:CGFloat = 0
    var initial:Bool = true
    
    init(frame: CGRect, count: Int) {
        super.init(frame: frame)
        
        self.count = CGFloat(count)
        
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panned))
        self.addGestureRecognizer(self.gestureRecognizer)
        
        self.touchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        self.addGestureRecognizer(self.touchGestureRecognizer)
        
        let layer:WireLayer = WireLayer()
        layer.frame = self.bounds
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        
        layer.color = Constant.COLORS[0]
        layer.currentPoint =  CGPoint(x: 10, y: Constant.mainControllCutoffMin)
        layer.offset = UIScreen.main.bounds.size.width/self.count/2
        
        layer.timelinePoint = CGPoint(x: layer.currentPoint.x, y: Constant.secondaryControlHeight)
        layer.timelineOffset = layer.offset
        
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
                                         y: Int(Constant.mainControllCutoffMin))
            layer.offset = UIScreen.main.bounds.size.width/self.count * CGFloat(i) + UIScreen.main.bounds.size.width/self.count/2
            
            layer.timelinePoint = CGPoint(x: layer.currentPoint.x, y: Constant.secondaryControlHeight)
            layer.timelineOffset = layer.offset
            
            self.layer.addSublayer(layer)
            layer.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (i, layer) in self.layer.sublayers!.enumerated() {
            (layer as! WireLayer).frame = self.bounds
            
            if !self.initial {
                (layer as! WireLayer).currentPoint = CGPoint(x: Int(UIScreen.main.bounds.size.width*self.getPercentageX(index: i)), y: Int(Constant.controlSurfaceHeight-Constant.controlSurfaceHeight*self.getPercentageY(index: i)))
            }
            
            (layer as! WireLayer).offset = UIScreen.main.bounds.size.width/self.count * CGFloat(i) + UIScreen.main.bounds.size.width/self.count/2
            (layer as! WireLayer).setNeedsDisplay()
        }
        
        self.initial = false
        self.previousScreenWidth = UIScreen.main.bounds.size.width
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPoint(for index: Int) -> CGPoint {
        let point = (self.layer.sublayers![index] as! WireLayer).currentPoint
        return CGPoint(x: point.x + 15, y: point.y + 15)
    }
    
    func getPercentageX(index: Int) -> CGFloat {
        let layer:WireLayer = self.layer.sublayers![index] as! WireLayer
        //fabs((layer.currentPoint.x / self.previousScreenWidth) - (layer.offset/self.previousScreenWidth)) as CGFloat
        return layer.currentPoint.x / self.previousScreenWidth
    }
    
    func getSpeedPercentageX(index: Int) -> CGFloat {
        let layer:WireLayer = self.layer.sublayers![index] as! WireLayer
        return ((layer.currentPoint.x / self.previousScreenWidth) - (layer.offset/self.previousScreenWidth)) as CGFloat
    }
    
    func getPercentageY(index: Int) -> CGFloat {
        guard let layer:WireLayer = self.layer.sublayers![index] as? WireLayer else {
            return 0
        }
        return (Constant.controlSurfaceHeight-layer.currentPoint.y)/Constant.controlSurfaceHeight
    }
    
    func getTimelinePercentageX(index: Int) -> CGFloat {
        let layer:WireLayer = self.layer.sublayers![index] as! WireLayer
        return layer.timelinePoint.x / self.previousScreenWidth
    }
    
    func getTimelinePercentageY(index: Int) -> CGFloat {
        guard let layer:WireLayer = self.layer.sublayers![index] as? WireLayer else {
            return 0
        }
        return (Constant.controlSurfaceHeight-layer.timelinePoint.y)/Constant.controlSurfaceHeight
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
                    self.delegate.slidingHasBegun(point: point)
                } else if (wireLayer as! WireLayer).timelineRect.contains(point) {
                    self.currentLayerIndex = i
                    self.shouldRedrawTimeline = true
                    (wireLayer as! WireLayer).selected = true
                    self.delegate.timelineScrubbingHasBegun(point: point)
                }
            }
            break
            
        case .changed:
            if self.shouldRedraw {
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).currentPoint = point
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()

                if (self.delegate != nil) {
                    self.delegate.percentageOfWidth(index: self.currentLayerIndex,
                                                    percentageX: self.getPercentageX(index: self.currentLayerIndex),
                                                    percentageY: self.getPercentageY(index: self.currentLayerIndex),
                                                    point: point)
                }
            } else if self.shouldRedrawTimeline {
                let currentTimelinePoint:CGPoint =  (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).timelinePoint
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).timelinePoint = CGPoint(x: point.x, y: currentTimelinePoint.y)
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()
                
                if (self.delegate != nil) {
                    self.delegate.timelinePercentageOfWidth(index: self.currentLayerIndex,
                                                    percentageX: self.getTimelinePercentageX(index: self.currentLayerIndex),
                                                    percentageY: self.getTimelinePercentageY(index: self.currentLayerIndex),
                                                    point: point)
                }
            }
            break
            
        case .ended:
            if self.shouldRedraw {
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).selected = false
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()
                self.delegate.slidingHasEnded(point: point)
                self.shouldRedraw = false
                self.currentLayerIndex = 0
            } else if self.shouldRedrawTimeline {
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).selected = false
                (self.layer.sublayers![self.currentLayerIndex] as! WireLayer).setNeedsDisplay()
                self.delegate.timelineScrubbingHasEnded(point: point)
                self.shouldRedrawTimeline = false
                self.currentLayerIndex = 0
            }
            break
        case .cancelled:
            self.shouldRedraw = false
            self.shouldRedrawTimeline = false
            break
        case .failed:
            self.shouldRedraw = false
            self.shouldRedrawTimeline = false
            break
            
        default:
            print("no bueno")
        }
        
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        self.delegate.tapped()
    }
    
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if (event == "contents") {
            return nil
        }
        
        return super.action(for: layer, forKey: event)
    }
}
