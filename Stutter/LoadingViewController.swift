//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import ParticlesLoadingView
import LLSpinner
import AVFoundation
import AnimatablePlayButton

class LoadingViewController : UIViewController {
    
    let previewFinalVideoView:PreviewFinalVideoView = PreviewFinalVideoView(frame: CGRect.zero)
    
    let playButton:AnimatablePlayButton = {
        let button = AnimatablePlayButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bgColor = .black
        button.color = .white
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewFinalVideoView.backgroundColor = UIColor.black
        
        self.view.addSubview(self.previewFinalVideoView)
        self.previewFinalVideoView.addSubview(self.playButton)
        
        self.previewFinalVideoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.previewFinalVideoView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.previewFinalVideoView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.previewFinalVideoView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playButton.centerXAnchor.constraint(equalTo: self.previewFinalVideoView.centerXAnchor).isActive = true
        self.playButton.centerYAnchor.constraint(equalTo: self.previewFinalVideoView.centerYAnchor).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.6)) {
//            LLSpinner.stop()
//        }
    }
    
    func playButtonPressed() {
        self.previewFinalVideoView.isHidden = false
//        self.previewFinalVideoView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.mutableComposition))
//        self.previewFinalVideoView.player?.play()
    }

    func stopButtonPressed() {
        self.previewFinalVideoView.player?.pause()
        self.previewFinalVideoView.player = nil
        self.previewFinalVideoView.isHidden = true
    }
    
    func tapped(sender: AnimatablePlayButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }
}
