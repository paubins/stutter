//
//  ScrubberViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
class ScrubberPreviewViewController : UIViewController {
    lazy var cameraScrubberPreviewView:CameraScrubberPreviewView = {
        return CameraScrubberPreviewView(frame: CGRect.zero)
    }()
    
    var cameraScrubberPreviewConstraint:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        self.view.addSubview(self.cameraScrubberPreviewView)
        
        constrain(self.cameraScrubberPreviewView) { (view) in
            view.height == 50
            view.bottom == view.superview!.bottom
        }
        
        self.cameraScrubberPreviewView.isHidden = true
        
        self.cameraScrubberPreviewConstraint = self.cameraScrubberPreviewView.widthAnchor.constraint(equalToConstant: 50)
        self.cameraScrubberPreviewConstraint.isActive = true
    }
    
    func load(asset: AVAsset) {
        self.cameraScrubberPreviewView.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
    }
    
    func show() {
        self.cameraScrubberPreviewView.isHidden = false
    }
    
    func hide() {
        self.cameraScrubberPreviewView.isHidden = true
    }
    
    func seek(to: CMTime, distance: Int) {
        self.cameraScrubberPreviewConstraint.constant = 20 + CGFloat(distance)
        self.cameraScrubberPreviewView.playerView.player?.seek(to: to,
                                                               toleranceBefore: CMTimeMake(1, 60),
                                                               toleranceAfter: CMTimeMake(1, 60))
    }
}
