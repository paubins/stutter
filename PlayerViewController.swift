//
//  PlayerController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Player
import Cartography

class PlayerViewController : UIViewController {
    var playbackDelegate:PlayerPlaybackDelegate!
    
    lazy var player:Player = {
        return Player()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        self.player.playbackDelegate = self.playbackDelegate
        self.player.view.frame = self.view.bounds
        self.player.fillMode = AVLayerVideoGravity.resizeAspect
        self.player.playbackLoops = true
        self.player.view.backgroundColor = .clear
        self.player.playbackResumesWhenEnteringForeground = false
        
        self.view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.view.addSubview(self.player.view)
        
        constrain(self.player.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player.stop()
    }
    
    func play() {
        self.player.playFromBeginning()
    }
    
    func stop() {
        self.player.stop()
    }
    
    func load(asset: AVAsset) {
        self.player.url = (asset as! AVURLAsset).url
    }
    
    func seekToTime(time: CMTime) {
        self.player.seekToTime(to: time,
                               toleranceBefore: CMTimeMake(value: 1, timescale: 600),
                               toleranceAfter: CMTimeMake(value: 1, timescale: 600))
        self.player.playFromCurrentTime()
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.location(in: self.view).x < UIScreen.main.bounds.width/4) {
            self.play()
        } else if self.player.playbackState == .playing {
            self.stop()
        } else {
            self.player.playFromCurrentTime()
        }
    }
}
