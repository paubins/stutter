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
    lazy var zoomLevelView:ZoomLevelView = {
        let zoomLevelView:ZoomLevelView = ZoomLevelView(frame: .zero)
        return zoomLevelView
    }()
    
    var exportAlert:FCAlertView!
    
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
    
    lazy var scrubberPreviewViewController:Player = {
        let scrubberPreviewViewController:Player = Player()
        scrubberPreviewViewController.view.backgroundColor = .clear
        scrubberPreviewViewController.playbackResumesWhenEnteringForeground = false
        scrubberPreviewViewController.view.isHidden = true
        return scrubberPreviewViewController
    }()
    
    lazy var playerViewController:Player = {
        let player:Player = Player()
        
        player.playbackDelegate = self
        player.view.frame = self.view.bounds
        player.fillMode = AVLayerVideoGravityResizeAspect
        player.playbackLoops = false
        player.view.backgroundColor = .clear
        player.playbackResumesWhenEnteringForeground = false
        
        player.view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerViewtapped))
        player.view.addGestureRecognizer(tapGestureRecognizer)
        
        return player
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

//        let appleValidator = AppleReceiptValidator(service: .production)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            switch result {
//            case .success(let receipt):
//                // Verify the purchase of Consumable or NonConsumable
//                let purchaseResult = SwiftyStoreKit.verifyPurchase(
//                    productId: "com.musevisions.SwiftyStoreKit.Purchase1",
//                    inReceipt: receipt)
//
//                switch purchaseResult {
//                case .purchased(let receiptItem):
//                    print("Product is purchased: \(receiptItem)")
//                    self.downloadQueueViewController.timerLabel.addTimeCounted(byTime: 15)
//
//                case .notPurchased:
//                    print("The user has never purchased this product")
//                }
//            case .error(let error):
//                print("Receipt verification failed: \(error)")
//            }
//        }
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
        self.addChildViewController(self.scrubberPreviewViewController)
        
        self.view.addSubview(self.backgroundShiftView)
        self.view.addSubview(self.playerViewController.view)
        self.view.addSubview(self.zoomLevelView)
        self.view.addSubview(self.mainControlViewController.view)
        self.view.addSubview(self.buttonViewController.view)
        self.view.addSubview(self.downloadQueueViewController.view)
        self.view.addSubview(self.scrubberPreviewViewController.view)
        
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
            
            view.height == 150
            view.width == 90
        }
        
        constrain(self.mainControlViewController.view) { (view) in
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
            view.height == Constant.mainControlHeight
        }
        
        constrain(self.downloadQueueViewController.view) { (view) in
            view.right == view.superview!.right
            view.top == view.superview!.top
            view.width == 90
            view.height == 150
        }
        
        constrain(self.scrubberPreviewViewController.view) { (view) in
            view.height == 50
            view.width == 50
        }
        
        constrain(self.buttonViewController.view, self.zoomLevelView) { (view1, view2) in
            view1.bottom == view2.top
            view2.left == view2.superview!.left
            view2.height == 200
            view2.width == 90
        }
        
        self.backgroundShiftView.animationDuration(20.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrubberPreviewViewController.view.isHidden = true
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
    
    func playerViewtapped(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.location(in: self.view).x < UIScreen.main.bounds.width/4) {
            self.playerViewController.playFromBeginning()
        } else if self.playerViewController.playbackState == .playing {
            self.playerViewController.stop()
        } else {
            self.playerViewController.playFromCurrentTime()
        }
    }
}

extension ViewController : ButtonViewControllerDelegate {
    
    func assetChosen(asset: AVAsset) {
        self.editController = EditController(asset: asset)
        
        if (self.stutterState != .exporting) {
            self.downloadQueueViewController.turnOffShareButton()
            self.downloadQueueViewController.timerLabel.reset()
        }
        
        self.mainControlViewController.asset = asset
        self.playerViewController.url = (asset as! AVURLAsset).url
        self.scrubberPreviewViewController.url = (asset as! AVURLAsset).url
        self.scrubberPreviewViewController.view.isHidden = true
        
        asset.getAudio(completion: { (duration, url) in
            let size:CGSize = asset.getSize()
            self.editController.load(duration: duration, size: size)
            self.mainControlViewController.load(duration: duration, audioURL: url, size: size)
            
            try! FileManager.default.removeItem(at: url)
            
            let newSize:CGSize = AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: 100, height: 50)).size
            
            asset.getThumbnails(size: newSize, completionHandler: { (images) in
                DispatchQueue.main.sync {
                    self.mainControlViewController.loadThumbnails(images: images)
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
                
                if (self.exportAlert != nil) {
                    self.exportAlert.dismiss()
                }
                
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
    func tapped() {
        switch self.playerViewController.playbackState {
        case .playing:
            self.playerViewController.pause()
            break
        case .paused:
            self.playerViewController.playFromCurrentTime()
            break
        case .stopped:
            self.playerViewController.playFromBeginning()
            break
        default:
            break
        }
    }
    
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
            
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            break
        case .recording:
            time = editController.storeEdit(percentageOfTime: percentageX, percentageZoom: percentageY)
            
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            break
        case .paused:
            self.stutterState = .recording
            self.downloadQueueViewController.timerLabel.start()
            self.downloadQueueViewController.turnOnShareButton()
            time = editController.storeEdit(percentageOfTime: percentageX, percentageZoom: percentageY)
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            
            break
        case .exporting:
            if (self.exportAlert == nil) {
                self.exportAlert = FCAlertView()
                exportAlert.makeAlertTypeWarning()
                exportAlert.showAlert(inView: self,
                                      withTitle: "Currently exporting!",
                                      withSubtitle: "lil stutter is saving your video!",
                                      withCustomImage: nil,
                                      withDoneButtonTitle: "👌",
                                      andButtons: nil)
                
                exportAlert.colorScheme = UIColor(hex: "#8C9AFF")
            }
            return
        default:
            break
        }
        
        self.playerViewController.seekToTime(to: time, toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        self.playerViewController.playFromCurrentTime()
    }
    
    func scrubbingHasBegun(at point: CGPoint) {
        print("cool")
        self.scrubberPreviewViewController.view.frame.origin = Constant.addInset(to: point)
        self.scrubberPreviewViewController.view.isHidden = false
    }
    

    func scrubbingHasMoved(index: Int, percentageX: CGFloat, percentageY: CGFloat, to point: CGPoint) {
        if (self.editController == nil) {
            return
        }
        
        self.scrubberPreviewViewController.view.frame.origin = Constant.addInset(to: point)
        self.scrubberPreviewViewController.view.layer.transform = CATransform3DMakeScale(percentageY+1, percentageY+1, 1)
        
        self.scrubberPreviewViewController.seekToTime(to: CMTimeMakeWithSeconds(Float64(CGFloat(CMTimeGetSeconds(self.editController.currentAssetDuration)) * percentageX), 60), toleranceBefore: CMTimeMake(1, 60), toleranceAfter: CMTimeMake(1, 60))
        
    }
    
    func scrubbingHasEnded(at point: CGPoint) {
        self.scrubberPreviewViewController.view.isHidden = true
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
//        if (self.stutterState == .recording) {
//            self.editController.closeEdit()
//        }
    }
}

extension ViewController : PlayerDelegate {
    func playerReady(_ player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        switch player.playbackState {
        case .playing:
            switch self.stutterState {
            case .recording:
                let _:CMTime = self.editController.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0)
                self.downloadQueueViewController.timerLabel.start()
                self.stutterState = .recording
            default:
                print("default")
            }
            break
            
        case .paused:
            switch self.stutterState {
            case .recording:
                let _:CMTime = self.editController.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0)
                
                self.downloadQueueViewController.timerLabel.pause()
                self.stutterState = .paused
            default:
                print("default")
            }
            break
        default:
            print("unknown")
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    //this is the time in seconds that the video has buffered to.
    //If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
}


extension ViewController : FCAlertViewDelegate {
    func fcAlertViewDismissed(_ alertView: FCAlertView!) {
        self.downloadQueueViewController.turnOffShareButton()
    }
}
