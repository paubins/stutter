//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography

class LoadingViewController : UIViewController {
    var progressTimer:Timer!
    
    var completion:(() -> Void)!
    
    lazy var progress: UIProgressView = {
        let progress:UIProgressView = UIProgressView(frame: .zero)
        progress.isHidden = false
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
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            if (exportSession.progress == 1.0) {
                self.progress.progress = exportSession.progress
                
                self.completion = completion
                
                let alert:UIAlertController = UIAlertController()
                alert.title = "Saved!"
                alert.message = "Your video saved!"
                
                let action:UIAlertAction = UIAlertAction(title: "Ok!",
                                                         style: .default,
                                                         handler: { (action) in
                                                            self.progress.progress = 0.0
                                                            self.completion()
                })
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: { })
                
                self.progressTimer.invalidate()
                self.progressTimer = nil
            } else {
                self.progress.progress = exportSession.progress
            }
        }
    }
    
    @objc func saveCompleted(video: String, didFinishSavingWithError: Error, contextInfo: UnsafeMutableRawPointer) {

    }
}
