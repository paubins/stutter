//
//  WaveformCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import FDWaveformView
import Cartography
import Shift

class WaveformCollectionViewCell : UICollectionViewCell {
    lazy var waveformView:FDWaveformView = {
        let newWaveForm:FDWaveformView = FDWaveformView()
        newWaveForm.backgroundColor = UIColor.clear
        newWaveForm.translatesAutoresizingMaskIntoConstraints = false
        newWaveForm.wavesColor = Constant.wavesColor
        newWaveForm.doesAllowScrubbing = false
        newWaveForm.doesAllowScroll = false
        newWaveForm.doesAllowStretch = false
        newWaveForm.delegate = self
        return newWaveForm
    }()

    lazy var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors(Constant.COLORS)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backgroundShiftView)
        self.addSubview(self.waveformView)
        
        constrain(self.waveformView, self.backgroundShiftView) { (view, view1) in
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
            view.right == view.superview!.right
            view.left == view.superview!.left
            
            view1.right == view1.superview!.right
            view1.left == view1.superview!.left
            view1.top == view1.superview!.top
            view1.bottom == view1.superview!.bottom
        }
        
        self.backgroundShiftView.animationDuration(10.0)
        self.backgroundShiftView.startTimedAnimation()
    }
    
    func updateAudioURL(audioURL: URL) {
        self.waveformView.audioURL = audioURL
    }
    
    func updateColor(color: UIColor) {
        self.waveformView.progressColor = color
    }
    
    func updateProgressSamples(distance: CGFloat) {
        self.waveformView.progressSamples = Int((distance + 10)/self.frame.width * CGFloat(self.waveformView.totalSamples))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WaveformCollectionViewCell : FDWaveformViewDelegate {
    func waveformViewDidLoad(_ waveformView: FDWaveformView) {
        self.backgroundShiftView.isHidden = true
        print("wave loaded")
    }
}
