//
//  LoadingViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import LLSpinner
import AVFoundation
import AnimatablePlayButton
import VIMVideoPlayer
import DynamicButton
import Cartography

protocol LoadingViewControllerDelegate {
    func exportSucessful(controller: UIViewController)
}

class LoadingViewController : UIViewController {
    
    let playButton:AnimatablePlayButton = {
        let button = AnimatablePlayButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bgColor = .black
        button.color = .white
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        button.select()
        
        return button
    }()
    
    let saveButton:DynamicButton = {
        let button:DynamicButton = DynamicButton(style: .fastForward)
        
        return button
    }()
    
    let videoPlayerView:VIMVideoPlayerView = {
        let vimPlayer:VIMVideoPlayerView = VIMVideoPlayerView()
        vimPlayer.translatesAutoresizingMaskIntoConstraints = false
        return vimPlayer
    }()
    
    var delegate:LoadingViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.backgroundColor = UIColor.black
        
        self.videoPlayerView.backgroundColor = UIColor.clear
        
        self.videoPlayerView.player.isLooping = false
        self.videoPlayerView.player.disableAirplay()
        self.videoPlayerView.setVideoFillMode(AVLayerVideoGravityResizeAspectFill)
        
        self.saveButton.addTarget(self, action: #selector(exportVideo), for: .touchUpInside)
        
        self.videoPlayerView.delegate = self
        
        self.view.addSubview(self.videoPlayerView)
        
        self.videoPlayerView.addSubview(self.playButton)
        self.view.addSubview(self.saveButton)
        
        constrain(self.saveButton) { (view) in
            view.right == (view.superview?.right)! - 50
            view.top == (view.superview?.top)! + 50
            view.height == 50
            view.width == 50
        }
        
        self.videoPlayerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.videoPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.videoPlayerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.videoPlayerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playButton.centerXAnchor.constraint(equalTo: self.videoPlayerView.centerXAnchor).isActive = true
        self.playButton.centerYAnchor.constraint(equalTo: self.videoPlayerView.centerYAnchor).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.view.backgroundColor = UIColor.black
    }
    
    func tapped(sender: AnimatablePlayButton) {
        if sender.isSelected {
            sender.deselect()
            self.videoPlayerView.player.play()
        } else {
            sender.select()
            self.videoPlayerView.player.pause()
        }
    }
    
    func exportVideo() {
        try? self.export(asset: (self.videoPlayerView.player.player.currentItem?.asset)!)
    }
    
    func export(asset: AVAsset) throws {
        let assetVideoTrack:AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).last!
        let videoCompositonTrack:AVMutableCompositionTrack = asset.tracks(withMediaType: AVMediaTypeVideo).last! as! AVMutableCompositionTrack
        videoCompositonTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        let exporter:AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        
        let filename = "composition.mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.outputURL = fileUrl
        
        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.6))
        
        exporter.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                if exporter.status == AVAssetExportSessionStatus.completed {
                    UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, nil, nil)
                    print("Success")
                    
                    self.dismiss(animated: true, completion: {
                        print("completed")
                        self.delegate.exportSucessful(controller: self)
                        
                        LLSpinner.stop()
                    })
                }
                else {
                    print(exporter.error?.localizedDescription ?? "error")
                    //The requested URL was not found on this server.
                }
            })
        })
    }

}

extension LoadingViewController : VIMVideoPlayerViewDelegate {
    
}
