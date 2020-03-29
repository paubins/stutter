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

protocol DownloadQueueViewControllerDelegate {
    func exportButtonTapped()
}

class DownloadQueueViewController : UIViewController {
    var delegate:DownloadQueueViewControllerDelegate!
    
    lazy var loadingViewController:LoadingViewController = {
        let loadingViewController = LoadingViewController()
        loadingViewController.view.alpha = 0.0
        
        return loadingViewController
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
        
        
        let shareIcon = FAKFontAwesome.downloadIcon(withSize: 40)
        let playStopBackButton:UIButton = UIButton()
        playStopBackButton.setImage(shareIcon?.image(with: CGSize(width: 40, height: 40)), for: .normal)
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
        
        self.view.addSubview(self.saveShareButton)
        self.view.addSubview(self.loadingViewController.view)
        
        constrain(self.saveShareButton, self.loadingViewController.view) { (view, view1) in
            view.right == view.superview!.right - 15
            view.top == view.superview!.top + 40
            view.height == 60
            view.width == 60
            
            view1.right == view1.superview!.right - 15
            view1.top == view1.superview!.top + 40
            view1.height == 60
            view1.width == 60
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.saveShareButton.makeCircular()
    }
    
    func saveVideo(sender: UIButton) {
        if (0.0 == self.loadingViewController.progress.progress) {
            self.delegate.exportButtonTapped()
        }
    }
    
    func turnOnShareButton() {
        if (self.saveShareButton.alpha == 0.0) {
            UIView.animate(withDuration: 0.5) {
                self.saveShareButton.alpha = 1.0
                self.loadingViewController.view.alpha = 1.0
            }
        }
    }
    
    func turnOffShareButton() {
        if (self.saveShareButton.alpha == 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.saveShareButton.alpha = 0.0
            }
        }
    }
    
    func updateProgress(exportSession: AVAssetExportSession) {
        self.loadingViewController.updateProgress(exportSession: exportSession, completion: {
            self.loadingViewController.view.alpha = 0.0
        })
    }
}
