//
//  ScrubberView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import AHKBendableView
import FDWaveformView

protocol ScrubberViewDelegate {
    func sliceWasMovedTo(index: Int, distance: Int)
    func draggingHasBegun(index: Int)
    func draggingHasEnded(index: Int)
}

class ScrubberView : UIView {
    var flippers:[NSLayoutConstraint] = []
    var slices:[BendableView] = []
    
    var length:Int = 0
    var imageView:UIView!
    var delegate: ScrubberViewDelegate?
    
    var previousThumbnail:UIImageView!
    var thumbnails:[UIImageView] = []
    
    var waveformView:FDWaveformView = {
        let newWaveForm:FDWaveformView = FDWaveformView()
        newWaveForm.backgroundColor = UIColor.clear
        newWaveForm.translatesAutoresizingMaskIntoConstraints = false
        newWaveForm.wavesColor = Constant.wavesColor
        newWaveForm.doesAllowScrubbing = false
        newWaveForm.doesAllowScroll = false
        newWaveForm.doesAllowStretch = false
        
        return newWaveForm
    }()
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.imageView = UIView(frame: .zero)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.imageView)
        self.addSubview(self.waveformView)
        
        self.waveformView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.waveformView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.waveformView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.waveformView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.imageView.heightAnchor.constraint(equalToConstant: Constant.scrubberViewHeight).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        var i = 0
        var padding = CGFloat(0)
        
        while(i < 5) {
            let flipper:UIView = UIView(frame: CGRect.zero)
            flipper.translatesAutoresizingMaskIntoConstraints = false
            flipper.backgroundColor = UIColor.clear
            
            let slice:BendableView = BendableView(frame: .zero)
            slice.translatesAutoresizingMaskIntoConstraints = false
            slice.backgroundColor = Constant.COLORS[i]
            
            flipper.addSubview(slice)
            
            slice.fillColor = Constant.COLORS[i]
            slice.damping = Constant.scrubberSliceDamping
            slice.initialSpringVelocity = Constant.scrubberSpringVelocity
            
            slice.topAnchor.constraint(equalTo: flipper.topAnchor).isActive = true
            slice.widthAnchor.constraint(equalToConstant: 3).isActive = true
            slice.heightAnchor.constraint(equalTo: flipper.heightAnchor).isActive = true
            slice.centerXAnchor.constraint(equalTo: flipper.centerXAnchor).isActive = true

            slices.append(slice)
            
            self.addSubview(flipper)
            
            slice.tag = i
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
                gestureRecognizer.delegate = self
                flipper.addGestureRecognizer(gestureRecognizer)
            }
            
            padding += Constant.flipperPadding
            i += 1
        }
    }
    
    func blowUpSliceAt(index: Int) {
        self.slices[index].shake()
        
        self.waveformView.progressColor = Constant.COLORS[index]
        
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
    
    func removeAllImages() {
        for subview in self.imageView.subviews {
            subview.removeFromSuperview()
        }
        
        self.thumbnails = []
    }
    
    func addImage(image: UIImage) {
        let newThumbnail:UIImageView = UIImageView(image: image)
        newThumbnail.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.addSubview(newThumbnail)
        
        newThumbnail.widthAnchor.constraint(equalToConstant: self.frame.size.width / 10).isActive = true
        newThumbnail.heightAnchor.constraint(equalTo: self.imageView.heightAnchor).isActive = true
        newThumbnail.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor).isActive = true
        
        if (self.thumbnails.count != 0) {
            newThumbnail.leftAnchor.constraint(equalTo: (self.thumbnails.last?.rightAnchor)!).isActive = true
        } else {
            newThumbnail.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        }

        self.thumbnails.append(newThumbnail)
    }
    
    func getSlicePosition(index:Int) -> CGFloat {
        return slices[index].superview!.frame.origin.x
    }
    
    @objc func tapped(gestureRecognizer: UILongPressGestureRecognizer) {
        print("tapped")
        let view = gestureRecognizer.view
        
        if (gestureRecognizer.state == .began) {
            self.delegate?.draggingHasBegun(index: (view?.tag)!)
        }
        
        if (gestureRecognizer.state == .ended) {
            self.delegate?.draggingHasEnded(index: (view?.tag)!)
        }
        
        let layoutConstraint:NSLayoutConstraint = self.flippers[view!.tag]
        if (gestureRecognizer.location(in: self.superview).x < (UIScreen.main.bounds.width - 10.0)) {
            layoutConstraint.constant = gestureRecognizer.location(in: self.superview).x
            let currentTime = Int(floor(Float(self.length) * Float((gestureRecognizer.location(in: self.superview).x/(UIScreen.main.bounds.width - 10.0)))))
            self.delegate?.sliceWasMovedTo(index: (view?.tag)!, distance: Int(gestureRecognizer.location(in: self.superview).x))
        }
    }
    
    func updateFlipper(index:Int, distance: CGFloat) {
        let layoutConstraint:NSLayoutConstraint = self.flippers[index]
        layoutConstraint.constant = distance
    }
    
    func resetTimes() {
        for slice:UIView in self.slices {
            let currentTime = Int(floor(Float(self.length) * Float(((slice.superview?.frame.origin.x)!/(UIScreen.main.bounds.width - 10.0)))))
            self.delegate?.sliceWasMovedTo(index: (slice.tag), distance: Int((slice.superview?.frame.origin.x)!))
        }
    }
    
    func clearThumbnails() {
        self.thumbnails = []
        
        for view in self.imageView.subviews {
            view.removeFromSuperview()
        }
    }
}

extension ScrubberView : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
