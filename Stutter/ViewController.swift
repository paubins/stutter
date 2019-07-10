//
//  ViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import SwiftyCam
import SwiftyButton
import FDWaveformView
import Player
import Device
import Cartography
import AVKit

class ViewController: UIViewController {
    var times:[Int: CMTime] = [0: CMTime.zero, 1: CMTime.zero, 2: CMTime.zero, 3: CMTime.zero, 4: CMTime.zero]
    var asset:AVAsset!
    var lastSelectedIndex:Int = -1
    
    lazy var scrubberPreviewViewController:ScrubberPreviewViewController = {
        let scrubberPreviewViewController:ScrubberPreviewViewController = ScrubberPreviewViewController()
        return scrubberPreviewViewController
    }()
    
    lazy var buttonViewController:ButtonViewController = {
        let buttonViewController:ButtonViewController = ButtonViewController()
        buttonViewController.delegate = self
        return buttonViewController
    }()
    
    lazy var mainControlViewController:MainControlViewController = {
        let mainControlViewController:MainControlViewController = MainControlViewController()
        mainControlViewController.delegate = self
        return mainControlViewController
    }()
    
    lazy var playerViewController:PlayerViewController = {
        let playerController:PlayerViewController = PlayerViewController()
        playerController.playbackDelegate = self
        return playerController
    }()
    
    var editController:EditController!
    
    let fireController:DazFireController = DazFireController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.backgroundColor = .clear
        
        self.addChild(self.buttonViewController)
        self.addChild(self.playerViewController)
        self.addChild(self.scrubberPreviewViewController)
        self.addChild(self.mainControlViewController)
        
        self.view.addSubview(self.playerViewController.view)
        self.view.addSubview(self.buttonViewController.view)
        self.view.addSubview(self.scrubberPreviewViewController.view)
        self.view.addSubview(self.mainControlViewController.view)
        
        constrain(self.playerViewController.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.buttonViewController.view, self.scrubberPreviewViewController.view) { (view, view1) in
            view.right == view.superview!.right
            view.top == view.superview!.top
            view.bottom == view1.top
            view.width == 150
        }
        
        constrain(self.scrubberPreviewViewController.view, self.mainControlViewController.view) { (view, view1) in
            view1.left == view1.superview!.left
            view1.right == view1.superview!.right
            view1.bottom == view1.superview!.bottom
            view1.height == 150
            
            view.height == 50
            view.bottom == view1.top
            view.left == view.superview!.left
            view.right == view.superview!.right
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : ButtonViewControllerDelegate {
    
    func assetChosen(asset: AVAsset) {
        self.editController = EditController(asset: asset)
        self.mainControlViewController.reset()
        
        self.buttonViewController.turnOffShareButton()
        
        asset.getAudio(completion: { (duration, url) in
            self.editController.load(duration: duration)
            self.mainControlViewController.load(duration: duration, audioURL: url)
            
            try! FileManager.default.removeItem(at: url)
            
            asset.getThumbnails(completionHandler: { (images) in
                DispatchQueue.main.sync {
                    self.mainControlViewController.loadThumbnails(images: images)
                    self.scrubberPreviewViewController.load(asset: asset)
                    self.playerViewController.load(asset: asset)
                    self.playerViewController.play()
                }
            })
        })
    }
    
    func exportButtonTapped() {
        if (self.editController != nil ) {
            self.editController.closeEdit()
            
            self.playerViewController.stop()
            self.buttonViewController.turnOffShareButton()
            
            self.buttonViewController.updateProgress(exportSession: try! self.editController.export())
        }
    }
}

extension ViewController : MainControlViewControllerDelegate {
    func playerButtonWasTapped(index: Int) {
        if (self.editController != nil) {
            self.buttonViewController.turnOnShareButton()
            
            self.editController.storeEdit(time: self.times[index]!)
            self.playerViewController.seekToTime(time: self.times[index]!)
            
            self.lastSelectedIndex = index
        }
    }
    
    func sliceWasMoved(index: Int, distance: Int) {
        if (self.editController != nil) {
            let time:CMTime = self.editController.secondsFrom(percentage: CGFloat(distance)/UIScreen.main.bounds.width)
            self.scrubberPreviewViewController.seek(to: time, distance: distance)
            self.times[index] = time
        }
    }
    
    func draggingHasBegun(index: Int) {
        self.scrubberPreviewViewController.show()
    }
    
    func draggingHasEnded(index: Int) {
        self.scrubberPreviewViewController.hide()
    }
}


extension ViewController: PlayerPlaybackDelegate {
    
    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    public func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    public func playerCurrentTimeDidChange(_ player: Player) {
        self.mainControlViewController.assetTimeChanged(player: player)
    }
    
    public func playerPlaybackWillLoop(_ player: Player) {
        if (0 <= self.lastSelectedIndex) {
            self.editController.closeEdit()
        }
    }
}
