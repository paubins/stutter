//
//  PlayerView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/23/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import AVKit
import AVFoundation
import UIKit

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPlayerItem(playerItem: AVPlayerItem) {
        self.player = AVPlayer(playerItem: playerItem)
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        print("Video Finished")
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
}
