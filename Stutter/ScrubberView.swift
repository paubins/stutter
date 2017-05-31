//
//  ScrubberView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import AHKBendableView

protocol ScrubberViewDelegate {
    func sliceWasMovedTo(index: Int, time: Int, distance: Int)
    func draggingHasBegun()
    func draggingHasEnded()
}

class ScrubberView : UIView {
    var flippers:[NSLayoutConstraint] = []
    var slices:[BendableView] = []
    
    var length:Int = 0
    
    var delegate: ScrubberViewDelegate?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
//        self.backgroundColor = UIColor(rgbColorCodeRed: 155, green: 193, blue: 255, alpha: 1.0)
        
        var i = 0
        var padding = CGFloat(0)
        
        let colors = [UIColor(rgbColorCodeRed: 135, green: 135, blue: 135, alpha: 1.0),
                      UIColor(rgbColorCodeRed: 105, green: 105, blue: 198, alpha: 1.0),
                      UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                      UIColor(rgbColorCodeRed: 45, green: 45, blue: 89, alpha: 1.0),
                      UIColor(rgbColorCodeRed: 73, green: 73, blue: 73, alpha: 1.0)]
        
        while(i < 5) {
            let flipper:UIView = UIView(frame: CGRect.zero)
            flipper.translatesAutoresizingMaskIntoConstraints = false
            flipper.backgroundColor = UIColor.clear
            
            let slice:BendableView = BendableView(frame: .zero)
            slice.translatesAutoresizingMaskIntoConstraints = false
            slice.backgroundColor = colors[i]
            
            flipper.addSubview(slice)
            
            slice.fillColor = colors[i]
            slice.damping = 0.7
            slice.initialSpringVelocity = 0.8
            
            slice.topAnchor.constraint(equalTo: flipper.topAnchor).isActive = true
            slice.widthAnchor.constraint(equalToConstant: 5).isActive = true
            slice.heightAnchor.constraint(equalTo: flipper.heightAnchor).isActive = true
            slice.centerXAnchor.constraint(equalTo: flipper.centerXAnchor).isActive = true
            
            slices.append(slice)
            
            self.addSubview(flipper)
            
            flipper.tag = i
            flipper.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            
            if (i == 0) {
                flipper.widthAnchor.constraint(equalToConstant: 5).isActive = true
            } else {
                flipper.widthAnchor.constraint(equalToConstant: 20).isActive = true
            }
            
            flipper.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            
            let layoutConstraint = flipper.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding)
            layoutConstraint.isActive = true
            
            flippers.append(layoutConstraint)
            
            if (i != 0) {
                flipper.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.tapped)))
            }
            
            padding += CGFloat(50.0)
            i += 1
        }
    }
    
    func blowUpSliceAt(index: Int) {
        self.slices[index].shake()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .allowUserInteraction, animations: {
            self.slices[index].frame.origin.x += 5
            self.slices[index].frame.origin.x -= 5
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScrubberView {
    
    func tapped(gestureRecognizer: UILongPressGestureRecognizer) {
        print("tapped")
        
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            self.delegate?.draggingHasBegun()
        }
        
        if (gestureRecognizer.state == .ended) {
            self.delegate?.draggingHasEnded()
        }
        
        let view = gestureRecognizer.view
        let layoutConstraint:NSLayoutConstraint = self.flippers[view!.tag]
        if (gestureRecognizer.location(in: self.superview).x < (UIScreen.main.bounds.width - 10.0)) {
            layoutConstraint.constant = gestureRecognizer.location(in: self.superview).x
            let currentTime = Int(floor(Float(self.length) * Float((gestureRecognizer.location(in: self.superview).x/(UIScreen.main.bounds.width - 10.0)))))
            self.delegate?.sliceWasMovedTo(index: (view?.tag)!, time: currentTime, distance: Int(gestureRecognizer.location(in: self.superview).x))
        }
    }
}
