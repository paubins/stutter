//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import KDCircularProgress
import Cartography
import FCAlertView

class LoadingViewController : UIViewController {
    var progressTimer:Timer!
    
    var completion:(() -> Void)!
    
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
        progress.set(colors: UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7"))
        
        return progress
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overCurrentContext
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true

        self.view.backgroundColor = .clear
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(self.progress)
        
        self.progress.backgroundColor = .clear
        
        constrain(self.progress) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
    }
    
    func updateProgress(exportSession: AVAssetExportSession, completion: @escaping () -> Void) {
        self.progressTimer = Timer.every(0.2.seconds) {
            if (exportSession.progress == 1.0) {
                self.progress.progress = Double(exportSession.progress)
                
                self.completion = completion
                
                let alert:FCAlertView = FCAlertView()
                alert.makeAlertTypeSuccess()
                alert.showAlert(inView: self,
                                withTitle: "Saved!",
                                withSubtitle: "Your video saved!",
                                withCustomImage: nil,
                                withDoneButtonTitle: "👌",
                                andButtons: nil)
                alert.delegate = self
                
                alert.colorScheme = UIColor(hex: "#8C9AFF")
                
                self.progressTimer.invalidate()
                self.progressTimer = nil
            } else {
                self.progress.progress = Double(exportSession.progress)
            }
        }
    }
    
    @objc func saveCompleted(video: String, didFinishSavingWithError: Error, contextInfo: UnsafeMutableRawPointer) {

    }
}

extension LoadingViewController : FCAlertViewDelegate {
    func fcAlertViewDismissed(_ alertView: FCAlertView!) {
        self.progress.progress = 0.0
        self.completion()
    }
}
