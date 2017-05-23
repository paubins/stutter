//
//  ScrubberView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

protocol ScrubberViewDelegate {
    func sliceWasMovedTo(time: Int)
}

class ScrubberView : UIView {
    var flippers:[NSLayoutConstraint] = []
    var slices:[UIView] = []
    
    var length:Int = 0
    
    var delegate: ScrubberViewDelegate?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.orange
        
        var i = 0
        var padding = CGFloat(0)
        
        let colors = [UIColor.black, UIColor.gray, UIColor.blue, UIColor.darkGray, UIColor.brown]
        
        while(i < 5) {
            let flipper:UIView = UIView(frame: CGRect.zero)
            flipper.translatesAutoresizingMaskIntoConstraints = false
            flipper.backgroundColor = UIColor.clear
            
            let slice:UIView = UIView(frame: CGRect.zero)
            slice.translatesAutoresizingMaskIntoConstraints = false
            slice.backgroundColor = colors[i]
            
            flipper.addSubview(slice)
            
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
            
            flipper.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.tapped)))
            
            padding += CGFloat(50.0)
            i += 1
        }
    }
    
    func blowUpSliceAt(index: Int) {
        self.slices[index].shake()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScrubberView {
    
    func tapped(gestureRecognizer: UILongPressGestureRecognizer) {
        print("tapped")
        
        let view = gestureRecognizer.view
        let layoutConstraint:NSLayoutConstraint = self.flippers[view!.tag]
        if (gestureRecognizer.location(in: self.superview).x < UIScreen.main.bounds.width - 10) {
            layoutConstraint.constant = gestureRecognizer.location(in: self.superview).x
            let currentTime = Int(floor(Float(self.length) * Float((gestureRecognizer.location(in: self.superview).x/(UIScreen.main.bounds.width - 10)))))
            self.delegate?.sliceWasMovedTo(time: currentTime)
        }
    }
}
