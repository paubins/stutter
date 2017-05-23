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

let WIDTH_CONSTANT = CGFloat(70.0)

var TIMES = [0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0]

class ViewController: UIViewController {
    
    let progressView:ProgressView = ProgressView(frame: CGRect.zero)
    var scrubberView:ScrubberView = ScrubberView(frame: CGRect.zero)
    
    let cameraView:CameraView = CameraView(frame: CGRect.zero)
    let exportButton:ExportView = ExportView(frame: CGRect.zero)
    let playButtonsView:PlayButtonsView = PlayButtonsView(frame: CGRect.zero)
    let playerView:PlayerView = PlayerView(frame: CGRect.zero)
    let previewFinalVideoView:PreviewFinalVideoView = PreviewFinalVideoView(frame: CGRect.zero)
    
    var currentPlayTimeInSeconds:Float = 0
    var currentPlayTimer:Timer!
    var currentAssetDuration:Float64 = 0
    var lastSelectedIndex:Int = 0
    var lastInsertedTime:CMTime = kCMTimeZero
    
    let asset:AVAsset = AVAsset.init(url: Bundle.main.url(forResource: "test", withExtension: "mp4")!)
    let mutableComposition:AVMutableComposition = AVMutableComposition()
    
    var exporter:AVAssetExportSession! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.scrubberView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.exportButton)
        self.view.addSubview(self.progressView)
        self.view.addSubview(self.playerView)
        self.view.addSubview(self.previewFinalVideoView)
        
        self.exportButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.exportButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.exportButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.exportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.progressView.bottomAnchor.constraint(equalTo: self.exportButton.topAnchor).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        self.progressView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.progressView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playButtonsView.bottomAnchor.constraint(equalTo: self.progressView.topAnchor).isActive = true
        self.playButtonsView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playButtonsView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.playButtonsView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.scrubberView.bottomAnchor.constraint(equalTo: self.playButtonsView.topAnchor).isActive = true
        self.scrubberView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrubberView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrubberView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.cameraView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.cameraView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.cameraView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.playerView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.playerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.playerView.isHidden = true
        
        self.previewFinalVideoView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.previewFinalVideoView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.previewFinalVideoView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.previewFinalVideoView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.previewFinalVideoView.isHidden = true
        
        self.cameraView.delegate = self
        self.scrubberView.delegate = self
        self.playButtonsView.delegate = self
        self.exportButton.delegate = self
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: break
        //handle authorized status
        case .denied, .restricted : break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized: break
                // as above
                case .denied, .restricted: break
                // as above
                case .notDetermined: break
                    // won't happen but still
                }
            }
        }
    }
    
    func export(composition: AVMutableComposition) throws {
        self.exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
        let filename = "composition.mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)

        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var error: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        self.exporter.outputFileType = AVFileTypeMPEG4
        self.exporter.outputURL = fileUrl
        
        self.exporter.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                if self.exporter.status == AVAssetExportSessionStatus.completed {
                    UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, nil, nil)
                    print("Success")
                    
                    self.resetButtonWasTapped()
                }
                else {
                    print(self.exporter.error?.localizedDescription)
                    //The requested URL was not found on this server.
                }
            })
        })
    }
    
    func insertNewEdit(index: Int, duration: Float) throws {
         try mutableComposition.insertTimeRange(CMTimeRangeMake(CMTimeMakeWithSeconds(TIMES[index]!, 30),
                                                                CMTimeMakeWithSeconds(Float64(duration), 30)),
                                                of: self.asset, at: self.lastInsertedTime)
        
        self.lastInsertedTime = CMTimeAdd(self.lastInsertedTime, CMTimeMakeWithSeconds(Float64(duration), 30))
    }
    
    func updateCurrentTime(timer: Timer) {
        self.currentPlayTimeInSeconds += 0.01
        
        if(self.currentAssetDuration < Double(self.currentPlayTimeInSeconds)) {
            do {
                try self.insertNewEdit(index: self.lastSelectedIndex, duration: self.currentPlayTimeInSeconds)
            } catch {
                print("something fucked up")
            }
            
            self.currentPlayTimeInSeconds = 0
            self.lastSelectedIndex = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : PlayButtonViewDelegate {
    func playButtonWasTapped(index: Int) {
        self.lastSelectedIndex = index
        
        self.scrubberView.blowUpSliceAt(index: index)
        self.progressView.updateProgress(index: index)
        
        self.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 30),
                                     toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        self.playerView.player?.play()
        
        if(self.currentPlayTimer != nil) {
            self.currentPlayTimer.invalidate()
            self.currentPlayTimer = nil
            
            do {
                try self.insertNewEdit(index: index, duration: self.currentPlayTimeInSeconds)
            } catch {
                print("something fucked up")
            }
            
            self.currentPlayTimeInSeconds = 0.0
        }
        
        self.currentPlayTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                                    selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
    }
}

extension ViewController : ExportViewDelegate {

    func exportButtonWasTapped() {
        print("exporting")
        
        self.checkPhotoLibraryPermission()
        do {
            try self.export(composition: self.mutableComposition)
        } catch {
            
        }
    }
    
    func playButtonWasTapped() {
        print("play new one")
        
        self.previewFinalVideoView.isHidden = false
        self.previewFinalVideoView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.mutableComposition))
        self.previewFinalVideoView.player?.play()
        
        self.progressView.playback()
    }
    
    func resetButtonWasTapped() {
        print("Reseting scrubs")
        
        self.previewFinalVideoView.player?.pause()
        self.previewFinalVideoView.player = nil
        self.previewFinalVideoView.isHidden = true
        
        self.playerView.player?.pause()
        self.playerView.player = nil
        self.playerView.isHidden = true
        
        self.progressView.resetProgress()
    }
}

extension ViewController : ScrubberViewDelegate {
    func sliceWasMovedTo(index: Int, time: Int) {
        
        if (self.playerView.player?.rate != 0) {
            self.playerView.player?.rate = 0
        }
        
        TIMES[index] = Double(time)*0.01
        
        self.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 30),
                                     toleranceBefore: CMTimeMake(1, 600),
                                     toleranceAfter: CMTimeMake(1, 600))
    }
}

extension ViewController : CameraViewDelegate {
    
    func recordingHasBegun() {

    }
    
    func recordingHasStoppedWithLength(time: Int) {
        self.scrubberView.length = time
        
        self.playerView.isHidden = false
        self.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        
        var time:Float64!
        
        self.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            switch(self.asset.statusOfValue(forKey: "duration", error: nil)) {
            case AVKeyValueStatus.loaded:
                time = CMTimeGetSeconds(self.asset.duration)
                self.scrubberView.length = Int(floor(time * 100))
                self.currentAssetDuration = time
                
                break
            default:
                break
            }
        }
    }
}
