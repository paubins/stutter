//
//  ShareViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/10/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import FCAlertView
import KDCircularProgress
import Cartography
import Shift

class ShareViewController : UIViewController {
    
    var showingExportAlert:Bool = false
    lazy var exportAlert:FCAlertView = {
        var exportAlert:FCAlertView = FCAlertView()
        exportAlert.makeAlertTypeWarning()
        exportAlert.colorScheme = Constant.COLORS[0]
        exportAlert.delegate = self
        
        return exportAlert
    }()
    
    var progressTimer:Timer!
    var completed:Bool = false
    
    lazy var progress: KDCircularProgress = {
        let progress:KDCircularProgress = KDCircularProgress(frame: .zero)
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.6
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.glowAmount = 0.9
        progress.isHidden = false
        progress.alpha = 1.0
        progress.set(colors: UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7"))
        
        progress.backgroundColor = .clear
        
        return progress
    }()
    
    lazy var exportView:UIButton = {
        let containerView:UIView = UIView(frame: .zero)
        containerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
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
        
        containerView.addSubview(playStopBackButton)
        
        constrain(playStopBackButton) { (view) in
            view.width == 30
            view.height == 30
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        containerView.alpha = 1.0
        
        return playStopBackButton
    }()
    
    var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        v.animationDuration(3)
        v.setColors(Constant.DARKER_COLORS)
        return v
    }()
    
    lazy var backBarButtonItem:UIBarButtonItem = {
        let button:UIButton = UIButton.backButton()
        button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundShiftView.startTimedAnimation()
        
        self.view.addSubview(self.backgroundShiftView)
        self.view.addSubview(self.exportView)
        self.view.addSubview(self.progress)
        
        constrain(self.exportView, self.progress) { (exportView, progressView) in
            exportView.centerX == exportView.superview!.centerX
            exportView.centerY == exportView.superview!.centerY
            
            exportView.height == 200
            exportView.width == 200
            
            progressView.centerX == exportView.superview!.centerX
            progressView.centerY == progressView.superview!.centerY
            
            progressView.height == 200
            progressView.width == 200
        }
        
        
        constrain(self.backgroundShiftView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.progressTimer != nil) {
            self.resetTimers()
        }
        
        self.updateProgress(exportSession: try! EditController.shared.export(completionHandler: { (success) in
            DispatchQueue.main.async {
                self.exportAlert.dismiss()
                
                if (!success) {
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
                } else {
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
                }
            }
        }))
    }
    
    func resetTimers() {
        self.progressTimer.invalidate()
        self.progressTimer = nil
        self.progress.progress = 0.0
        self.completed = false
    }
    
    func updateProgress(exportSession: AVAssetExportSession) {

        self.progressTimer = Timer.every(0.2.seconds) {
            switch(exportSession.status) {
            case .completed:
                self.progressTimer.invalidate()
                DispatchQueue.main.async {
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((exportSession.outputURL?.relativePath)!)) {
                        UISaveVideoAtPathToSavedPhotosAlbum((exportSession.outputURL?.relativePath)!, self, nil, nil);
                    }
                }
                
                break
                
            case .cancelled:
                break
                
            case .exporting:
                self.progress.progress = Double(exportSession.progress)
                break
                
            case .failed:
                break
                
            case .unknown:
                break
                
            case .waiting:
                break
                
            default:
                break
            }
            
        }
    }
    
    @objc func back(buttonItem: UIBarButtonItem) {
        if (self.completed) {
            self.resetTimers()
            EditController.shared.reset()
            DispatchQueue.main.async {
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
            }
        } else if (!self.showingExportAlert) {
            self.exportAlert.showAlert(inView: self,
                                       withTitle: "Currently exporting!",
                                       withSubtitle: "lil stutter is saving your video!",
                                       withCustomImage: nil,
                                       withDoneButtonTitle: "👌",
                                       andButtons: nil)
        }
    }
}

extension ShareViewController : FCAlertViewDelegate {
    func fcAlertViewWillAppear(_ alertView: FCAlertView!) {
        if (alertView == self.exportAlert) {
            self.showingExportAlert = true
        }
    }
    
    func fcAlertViewDismissed(_ alertView: FCAlertView!) {
        if (alertView != self.exportAlert) {
            self.completed = true
        } else {
            self.showingExportAlert = false
        }
    }
}

