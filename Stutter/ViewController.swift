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
import ElasticTransition
import LLSpinner
import FDWaveformView
import VideoViewController
import DynamicButton
import Player
import Device
import Cartography
import Shift
import FCAlertView
import AVKit
import SwiftyTimer
import KDCircularProgress

class ViewController: UIViewController {
    var times:[Int: CMTime] = [0: kCMTimeZero, 1: kCMTimeZero, 2: kCMTimeZero, 3: kCMTimeZero, 4: kCMTimeZero]
    var asset:AVAsset!
    var lastSelectedIndex:Int = -1
    
    lazy var scrubberPreviewViewController:ScrubberPreviewViewController = {
        let scrubberPreviewViewController:ScrubberPreviewViewController = ScrubberPreviewViewController()
        return scrubberPreviewViewController
    }()
    
    lazy var loadingViewController:LoadingViewController = {
        return LoadingViewController()
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
    
    var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors([UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7")])
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.backgroundColor = .clear
        
        self.addChildViewController(self.buttonViewController)
        self.addChildViewController(self.playerViewController)
        self.addChildViewController(self.scrubberPreviewViewController)
        self.addChildViewController(self.mainControlViewController)
        
        self.view.addSubview(self.backgroundShiftView)
        self.view.addSubview(self.playerViewController.view)
        self.view.addSubview(self.buttonViewController.view)
        self.view.addSubview(self.scrubberPreviewViewController.view)
        self.view.addSubview(self.mainControlViewController.view)
        
        constrain(self.backgroundShiftView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
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
        
        self.backgroundShiftView.animationDuration(3.0)
        self.backgroundShiftView.startTimedAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("disappeared")
        self.mainControlViewController.reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dch_checkDeallocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : ButtonViewControllerDelegate {
    
    func assetChosen(asset: AVAsset) {
        self.editController = EditController(asset: asset)
        
        asset.getAudio(completion: { (time, url) in
            self.editController.load(time: time)
            self.mainControlViewController.load(time: time, audioURL: url)
            
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
        self.editController.storeEdit(time: kCMTimeZero)
        self.playerViewController.stop()
        
        self.present(self.loadingViewController, animated: true) {
            self.loadingViewController.updateProgress(exportSession: self.editController.exportSession())
        }
    }
}

extension ViewController : MainControlViewControllerDelegate {
    func playerButtonWasTapped(index: Int) {
        if (self.editController != nil) {
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
