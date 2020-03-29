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
import LLSpinner
import FDWaveformView
import Player
import Device
import Cartography
import Shift
import FCAlertView
import AVKit
import SwiftyTimer
import KDCircularProgress
import MZTimerLabel
import SwiftyStoreKit
import Hue

class ViewController: UIViewController {
    var stutterState:StutterState = .prearmed
    
    lazy var downloadQueueViewController:DownloadQueueViewController = {
        let downloadQueueViewController:DownloadQueueViewController = DownloadQueueViewController()
        downloadQueueViewController.delegate = self
        return downloadQueueViewController
    }()
    
    lazy var buttonViewController:ButtonViewController = {
        let buttonViewController:ButtonViewController = ButtonViewController()
        buttonViewController.delegate = self
        return buttonViewController
    }()
    
    lazy var mainControlViewController:MainCollectionViewController = {
        let flowLayout:MainCollectionViewLayout = MainCollectionViewLayout()
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        flowLayout.minimumInteritemSpacing = 0.0
        let mainControlViewController:MainCollectionViewController = MainCollectionViewController(collectionViewLayout: flowLayout)
        mainControlViewController.delegate = self
        return mainControlViewController
    }()
    
    lazy var playerViewController:PlayerViewController = {
        let playerController:PlayerViewController = PlayerViewController()
        playerController.playbackDelegate = self
        playerController.delegate = self
        return playerController
    }()
    
    var editController:EditController!
    
    let fireController:DazFireController = DazFireController()
    
    
    var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors(Constant.COLORS)
        return v
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: "com.musevisions.SwiftyStoreKit.Purchase1",
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("Product is purchased: \(receiptItem)")
                    self.downloadQueueViewController.timerLabel.addTimeCounted(byTime: 15)
                    
                case .notPurchased:
                    print("The user has never purchased this product")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.backgroundColor = .clear
        
        self.addChildViewController(self.buttonViewController)
        self.addChildViewController(self.playerViewController)
        self.addChildViewController(self.mainControlViewController)
        self.addChildViewController(self.downloadQueueViewController)
        
        self.view.addSubview(self.backgroundShiftView)
        self.view.addSubview(self.playerViewController.view)

        self.view.addSubview(self.mainControlViewController.view)
        self.view.addSubview(self.buttonViewController.view)
        self.view.addSubview(self.downloadQueueViewController.view)
        
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
        
        constrain(self.buttonViewController.view) { (view) in
            view.left == view.superview!.left
            view.top == view.superview!.top
            
            view.height == 300
            view.width == 90
        }
        
        constrain(self.mainControlViewController.view) { (view) in
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
            view.height == UIScreen.main.bounds.size.height
        }
        
        constrain(self.downloadQueueViewController.view) { (view) in
            view.right == view.superview!.right
            view.top == view.superview!.top
            view.width == 90
            view.height == 150
        }
        
        self.backgroundShiftView.animationDuration(3.0)
        self.backgroundShiftView.startTimedAnimation()
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
        
        if (self.stutterState != .exporting) {
            self.downloadQueueViewController.turnOffShareButton()
            self.downloadQueueViewController.timerLabel.reset()
        }
        
        asset.getAudio(completion: { (duration, url) in
            let size:CGSize = asset.getSize()
            self.editController.load(duration: duration, size: size)
            self.mainControlViewController.load(duration: duration, audioURL: url)
            
            try! FileManager.default.removeItem(at: url)
            
            
            let newSize:CGSize = AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: 100, height: 50)).size
            
            asset.getThumbnails(size: newSize, completionHandler: { (images) in
                DispatchQueue.main.sync {
                    self.mainControlViewController.loadThumbnails(images: images)
                    self.mainControlViewController.load(asset: asset)
                    
                    self.playerViewController.load(asset: asset)
                    self.playerViewController.play()
                    
                    self.stutterState = .prearmed
                }
            })
        })
    }
}

extension ViewController : DownloadQueueViewControllerDelegate {
    func armRecording() {
        self.stutterState = .armed
    }
    
    func exportButtonTapped() {
        guard self.stutterState == .recording || self.stutterState == .paused else {
            return
        }
        
        self.downloadQueueViewController.timerLabel.pause()
        
        self.editController.closeEdit()
        self.playerViewController.stop()
        self.stutterState = .exporting
        
        self.downloadQueueViewController.updateProgress(exportSession: try! self.editController.export(completionHandler: { (success) in
            DispatchQueue.main.async {
                self.stutterState = .prearmed
                self.downloadQueueViewController.timerLabel.reset()
                
                if (success) {
                    let alert:FCAlertView = FCAlertView()
                    alert.makeAlertTypeSuccess()
                    alert.showAlert(inView: self,
                                    withTitle: "Saved!",
                                    withSubtitle: "Your video saved!",
                                    withCustomImage: nil,
                                    withDoneButtonTitle: "👌",
                                    andButtons: nil)
                    
                    alert.colorScheme = UIColor(hex: "#8C9AFF")
                    alert.delegate = self
                } else {
                    let alert:FCAlertView = FCAlertView()
                    alert.makeAlertTypeCaution()
                    alert.showAlert(inView: self,
                                    withTitle: "Error!",
                                    withSubtitle: "Something went wrong!",
                                    withCustomImage: nil,
                                    withDoneButtonTitle: "Okay",
                                    andButtons: nil)
                    
                    alert.colorScheme = UIColor(hex: "#8C9AFF")
                    alert.delegate = self
                }
            }
        }))
    }
}

extension ViewController : MainCollectionViewControllerDelegate {

    func playButtonWasTapped(index: Int, percentageX: CGFloat, percentageY: CGFloat) {
        guard let editController = self.editController else {
            return
        }
        
        print("play button tapped")
        
        var time:CMTime = kCMTimeZero
        
        switch self.stutterState {
        case .prearmed:
            self.stutterState = .recording
            self.downloadQueueViewController.turnOnShareButton()
            time = editController.storeEdit(percentageOfTime: percentageX, percentageZoom: percentageY)
            self.downloadQueueViewController.timerLabel.start()
            break
        case .recording:
            time = editController.storeEdit(percentageOfTime: percentageX, percentageZoom: percentageY)
            break
        case .paused:
            self.stutterState = .recording
            self.downloadQueueViewController.timerLabel.start()
            self.downloadQueueViewController.turnOnShareButton()
            time = editController.storeEdit(percentageOfTime: percentageX, percentageZoom: percentageY)
            break
        default:
            break
        }
        
        self.playerViewController.seekToTime(time: time)
    }
}


extension ViewController: PlayerPlaybackDelegate {
    func playerPlaybackDidLoop(_ player: Player) {
        
    }

    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    public func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    public func playerCurrentTimeDidChange(_ player: Player) {
        self.mainControlViewController.assetTimeChanged(player: player)
    }
    
    public func playerPlaybackWillLoop(_ player: Player) {
        if (self.stutterState == .recording) {
            self.editController.closeEdit()
        }
    }
}

extension ViewController : FCAlertViewDelegate {
    func fcAlertViewDismissed(_ alertView: FCAlertView!) {
        self.downloadQueueViewController.turnOffShareButton()
    }
}

extension ViewController : PlayerViewControllerDelegate {
    func playbackResumed(player: Player) {
        switch self.stutterState {
        case .recording:
            let _:CMTime = self.editController.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0)
            self.downloadQueueViewController.timerLabel.start()
            self.stutterState = .recording
        default:
            print("default")
        }
    }
    
    func playbackPaused(player: Player) {
        switch self.stutterState {
        case .recording:
            let _:CMTime = self.editController.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0)
            
            self.downloadQueueViewController.timerLabel.pause()
            self.stutterState = .paused
        default:
            print("default")
        }
    }
}
