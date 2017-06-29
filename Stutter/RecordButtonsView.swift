//
//  ScrubberView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import Overlap

protocol RecordButtonsViewDelegate {
    func recordButtonSliceWasMovedTo(index: Int, time: Int, distance: Int)
    func recordButtonDraggingHasBegun()
    func recordButtonDraggingHasEnded()
}

class RecordButtonsView : UIView {
    var flippers:[NSLayoutConstraint] = []
    var slices:[BAPulseView] = []
    var length:Int = 0
    var delegate: RecordButtonsViewDelegate?
    var localTimer:Timer!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var i = 0
        var padding = CGFloat(0)
        
        while(i < 5) {
            let flipper:UIView = UIView(frame: CGRect.zero)
            flipper.translatesAutoresizingMaskIntoConstraints = false
            flipper.backgroundColor = UIColor.clear
            
            let slice:BAPulseView = BAPulseView(frame: .zero)
            slice.translatesAutoresizingMaskIntoConstraints = false
            slice.pulseStrokeColor = Constant.COLORS[i].cgColor
            
            flipper.addSubview(slice)
            
//            slice.topAnchor.constraint(equalTo: flipper.topAnchor).isActive = true
            slice.widthAnchor.constraint(equalToConstant: 20).isActive = true
            slice.heightAnchor.constraint(equalToConstant: 20).isActive = true
            slice.centerXAnchor.constraint(equalTo: flipper.centerXAnchor).isActive = true
            slice.centerYAnchor.constraint(equalTo: flipper.centerYAnchor, constant: CGFloat(i * 4)).isActive = true
            
            slices.append(slice)
            
            //Simple Usage ============================================================================
            
            
            //    Adjust Corner Radius (Rounded Edges) ====================================================
            //    pulseView.layer.cornerRadius = 20.0f;
            slice.pulseCornerRadius = 8.0;
            
            
            //    Adjust Corner Radius (Circle) ===========================================================

            
            
            //    Adjust Stroke Color =====================================================================
            slice.pulseStrokeColor = UIColor.red.cgColor
            
            
            //    Adjust Pulse LineWidth ==================================================================
            slice.pulseLineWidth = 1.0
            
            
            //    Adjust Pulse Radius =====================================================================
            slice.pulseRadius = 4
        
            
            //    Adjust Pulse Duration ====================================================================
            slice.pulseDuration = 3.0
            
            self.addSubview(flipper)
            
            slice.layer.cornerRadius = 10
            slice.pulseCornerRadius = 10;
            
            slice.backgroundColor = UIColor.black;
            
            flipper.tag = i
            flipper.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            
            if (i == 0) {
                flipper.widthAnchor.constraint(equalToConstant: Constant.flipperWidthFirst).isActive = true
            } else {
                flipper.widthAnchor.constraint(equalToConstant: Constant.flipperWidth).isActive = true
            }
            
            flipper.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            
            let layoutConstraint = flipper.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding)
            layoutConstraint.isActive = true
            
            flippers.append(layoutConstraint)
            
            if (i != 0) {
                let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.tapped))
                gestureRecognizer.minimumPressDuration = 0
                gestureRecognizer.delegate = self
                flipper.addGestureRecognizer(gestureRecognizer)
            }
            
            padding += Constant.flipperPadding
            i += 1
        }
        
        self.localTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            for slice in self.slices {
                slice.popAndPulse()
            }
        })
    }
    
    func updateFlipper(index:Int, distance: CGFloat) {
        let layoutConstraint:NSLayoutConstraint = self.flippers[index]
        layoutConstraint.constant = distance
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

extension RecordButtonsView {
    
    func getSlicePosition(index:Int) -> CGFloat {
        return slices[index].superview!.frame.origin.x
    }
    
    func tapped(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            self.delegate?.recordButtonDraggingHasBegun()
        }
        
        if (gestureRecognizer.state == .ended) {
            self.delegate?.recordButtonDraggingHasEnded()
        }
        
        let view = gestureRecognizer.view
        let layoutConstraint:NSLayoutConstraint = self.flippers[view!.tag]
        
        if (gestureRecognizer.location(in: self.superview).x < (UIScreen.main.bounds.width - 10.0)) {
            layoutConstraint.constant = gestureRecognizer.location(in: self.superview).x
            let currentTime = Int(floor(Float(self.length) * Float((gestureRecognizer.location(in: self.superview).x/(UIScreen.main.bounds.width - 10.0)))))
            self.delegate?.recordButtonSliceWasMovedTo(index: (view?.tag)!, time: currentTime, distance: Int(gestureRecognizer.location(in: self.superview).x))
        }
    }
}

extension RecordButtonsView : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
