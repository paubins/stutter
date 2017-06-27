//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import LLSpinner
import AVFoundation
import AnimatablePlayButton
import VIMVideoPlayer

class LoadingViewController : UIViewController {
    
    let playButton:AnimatablePlayButton = {
        let button = AnimatablePlayButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bgColor = .black
        button.color = .white
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        return button
    }()
    
    let videoPlayerView:VIMVideoPlayerView = {
        let vimPlayer:VIMVideoPlayerView = VIMVideoPlayerView()
        vimPlayer.translatesAutoresizingMaskIntoConstraints = false
        return vimPlayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.backgroundColor = UIColor.clear
        
        self.videoPlayerView.backgroundColor = UIColor.clear
        
        self.videoPlayerView.player.isLooping = false
        self.videoPlayerView.player.disableAirplay()
        self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspectFill)
        
        self.videoPlayerView.delegate = self
        
        self.view.addSubview(self.videoPlayerView)
        
        self.videoPlayerView.addSubview(self.playButton)
        
        self.videoPlayerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.videoPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.videoPlayerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.videoPlayerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playButton.centerXAnchor.constraint(equalTo: self.videoPlayerView.centerXAnchor).isActive = true
        self.playButton.centerYAnchor.constraint(equalTo: self.videoPlayerView.centerYAnchor).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.view.backgroundColor = UIColor.black
    }
    
    func tapped(sender: AnimatablePlayButton) {
        if sender.isSelected {
            sender.deselect()
            self.videoPlayerView.player.play()
        } else {
            sender.select()
            self.videoPlayerView.player.pause()
        }
    }
}

extension LoadingViewController : VIMVideoPlayerViewDelegate {
    
}
