//
//  PreviewViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/7/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import SwiftyButton
import Cartography
import AVKit
import Emoji
import Hue

class PreviewViewController : UIViewController {
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!

    lazy var backBarButtonItem:UIBarButtonItem = {
        let button:UIButton = UIButton.backButton()
        button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var nextBarButtonItem:UIBarButtonItem = {
        let button:UIButton = UIButton.saveButton()
        button.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var progressBar:LinearProgressBar = {
        var progressBar:LinearProgressBar = LinearProgressBar(frame: .zero)
        progressBar.trackColor = .black
        progressBar.backgroundColor = .clear
        progressBar.barThickness = 5
        return progressBar
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)

        let playerItem:AVPlayerItem = AVPlayerItem(asset: EditController.shared.mutableComposition)
        playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed
        playerItem.videoComposition = EditController.shared.getVideoComposition()
        self.player = AVPlayer(playerItem: playerItem)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(10, 30), queue: DispatchQueue(label: "com.ew.time")) { (time) in
            DispatchQueue.main.async {
                self.progressBar.progressValue = (CGFloat(CMTimeGetSeconds(self.player.currentTime())/CMTimeGetSeconds((self.player.currentItem?.asset.duration)!))) * 100
            }
        }
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.playerLayer)
        
        self.view.addSubview(self.progressBar)
        
        constrain(self.progressBar) { (progressBar) in
            progressBar.left == progressBar.superview!.left + 20
            progressBar.right == progressBar.superview!.right - 20
            progressBar.bottom == progressBar.superview!.bottom - 150
            progressBar.height == 5
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(play)))
        
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
        self.navigationItem.rightBarButtonItem = self.nextBarButtonItem
        self.navigationItem.titleView = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.player.rate = 0.0
    }
    
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    func play(sender: UITapGestureRecognizer) {
        if (self.player.rate == 1.0) {
            self.player.rate = 0.0
        } else {
            self.player.seek(to: kCMTimeZero)
            self.player.rate = 1.0
        }
    }
    
    func save(button: UIBarButtonItem) {
        print("cool")
        
        self.navigationController?.pushViewController(ShareViewController(), animated: true)
    }
    
    func back(button: PressableButton) {
        print("cool")
        EditController.shared.reset()
        self.navigationController?.popViewController(animated: true)
    }
}


