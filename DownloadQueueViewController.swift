//
//  DownloadQueueViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/27/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import FontAwesomeKit
import MZTimerLabel
import Emoji
import SwiftyStoreKit

protocol DownloadQueueViewControllerDelegate {
    func armRecording()
    func exportButtonTapped()
}

class DownloadQueueViewController : UIViewController {
    var delegate:DownloadQueueViewControllerDelegate!
    
    lazy var loadingViewController:LoadingViewController = {
        let loadingViewController = LoadingViewController()
        loadingViewController.view.alpha = 0.0
        
        return loadingViewController
    }()
    
    let openNodeButton:UIView = {
        let containerView:UIView = UIView(frame: .zero)
        containerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.clipsToBounds = true
        containerView.addSubview(blurEffectView)
        
        constrain(blurEffectView) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
        
        let playStopBackButton:UIButton = UIButton()
        playStopBackButton.setImage(ButtonIcons.downloadImage, for: .normal)
        playStopBackButton.addTarget(self, action: #selector(openVideos), for: .touchUpInside)
        
        containerView.addSubview(playStopBackButton)
        
        constrain(playStopBackButton) { (view) in
            view.width == 30
            view.height == 30
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        containerView.alpha = 0.0
        
        return containerView
    }()
    
    
    lazy var timerLabel:MZTimerLabel = {
        let timerLabel:MZTimerLabel = MZTimerLabel(timerType: MZTimerLabelTypeTimer)
        timerLabel.setCountDownTime(15)
        timerLabel.timeFormat = "s's'"
        timerLabel.timeLabel.textColor = UIColor.white
        timerLabel.timeLabel.font = UIFont.systemFont(ofSize: 30)
        timerLabel.timeLabel.textAlignment = .center
        timerLabel.adjustsFontSizeToFitWidth = true
        
        timerLabel.delegate = self
        
        return timerLabel
    }()
    
    lazy var buyButton:UIView = {
        let containerView:UIView = UIView(frame: .zero)
        containerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.clipsToBounds = true
        containerView.addSubview(blurEffectView)
        
        constrain(blurEffectView) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.buyMoreTime)))
        
        containerView.addSubview(self.timerLabel)
        
        constrain(self.timerLabel) { (view) in
            view.width == 40
            view.height == 40
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        self.timerLabel.timeLabel.setNeedsDisplay()
        
        return containerView
    }()
    
    let saveShareButton:UIView = {
        let containerView:UIView = UIView(frame: .zero)
        containerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.clipsToBounds = true
        containerView.addSubview(blurEffectView)
        
        constrain(blurEffectView) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
        
        let playStopBackButton:UIButton = UIButton()
        playStopBackButton.setTitle(":ok_hand:".emojiUnescapedString, for: .normal)
        playStopBackButton.addTarget(self, action: #selector(saveVideo), for: .touchUpInside)
        
        containerView.addSubview(playStopBackButton)
        
        constrain(playStopBackButton) { (view) in
            view.width == 30
            view.height == 30
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        containerView.alpha = 0.0
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.addChildViewController(self.loadingViewController)
        
        self.view.addSubview(self.buyButton)
        self.view.addSubview(self.saveShareButton)
        self.view.addSubview(self.openNodeButton)
        self.view.addSubview(self.loadingViewController.view)
        // self.view.addSubview(self.timerLabel)
        
        constrain(self.saveShareButton, self.loadingViewController.view, self.openNodeButton, self.buyButton) { (view, view1, view2, 
            view3) in
            
            view3.top == view3.superview!.top + 40
            view3.right == view3.superview!.right - 15
            view3.height == 60
            view3.width == 60
            
            view.right == view.superview!.right - 15
            view.top == view3.bottom + 15
            view.height == 60
            view.width == 60
            
            view1.right == view1.superview!.right - 15
            view1.top == view3.bottom + 15
            view1.height == 60
            view1.width == 60
            
            view1.bottom == view2.top
            view2.height == 60
            view2.width == 60
            view2.right == view2.superview!.right - 15
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.saveShareButton.makeCircular()
        self.buyButton.makeCircular()
    }
    
    func saveVideo(sender: UIButton) {
        if (0.0 == self.loadingViewController.progress.progress) {
            self.timerLabel.reset()
            self.delegate.exportButtonTapped()
        }
    }
    
    func turnOnShareButton() {
        if (self.saveShareButton.alpha == 0.0) {
            self.timerLabel.start()
            UIView.animate(withDuration: 0.5) {
                self.saveShareButton.alpha = 1.0
                self.loadingViewController.view.alpha = 1.0
            }
        }
    }
    
    func turnOffShareButton() {
        if (self.saveShareButton.alpha == 1.0) {
            self.timerLabel.pause()
            UIView.animate(withDuration: 0.5) {
                self.saveShareButton.alpha = 0.0
                self.loadingViewController.view.alpha = 0.0
            }
        }
    }
    
    func updateProgress(exportSession: AVAssetExportSession) {
        self.loadingViewController.updateProgress(exportSession: exportSession, completion: {
            self.turnOffShareButton()
        })
    }
    
    func openVideos() {

    }
    
    
    func buyMoreTime(sender: UITapGestureRecognizer) {
        SwiftyStoreKit.purchaseProduct("com.musevisions.SwiftyStoreKit.Purchase1", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
}

extension DownloadQueueViewController : MZTimerLabelDelegate {

    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        DispatchQueue.main.async {
            self.delegate.exportButtonTapped()
        }
    }
    
    func timerLabel(_ timerLabel: MZTimerLabel!, countingTo time: TimeInterval, timertype timerType: MZTimerLabelType) {
        //        self.imageView.image = self.generateBez(text: "\(Int(time))s")
    }
}
