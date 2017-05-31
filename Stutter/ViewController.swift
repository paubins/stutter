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

let WIDTH_CONSTANT = CGFloat(10.0)

var TIMES = [0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0]

extension UIColor {
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
}

class ViewController: UIViewController {
    
    let progressView:ProgressView = ProgressView(frame: CGRect.zero)
    var scrubberView:ScrubberView = ScrubberView(frame: CGRect.zero)
    
    let cameraView:CameraView = CameraView(frame: CGRect.zero)
    let exportButton:ExportView = ExportView(frame: CGRect.zero)
    let playButtonsView:PlayButtonsView = PlayButtonsView(frame: CGRect.zero)
    let playerView:PlayerView = PlayerView(frame: CGRect.zero)
    let previewFinalVideoView:PreviewFinalVideoView = PreviewFinalVideoView(frame: CGRect.zero)
    let cameraScrubberPreviewView:CameraScrubberPreviewView = CameraScrubberPreviewView(frame: CGRect.zero)
    
    let secondProgressBar:SegmentedProgressBar = SegmentedProgressBar(numberOfSegments: 5, duration: 5)
    
    var cameraScrubberPreviewConstraint:NSLayoutConstraint!
    
    var currentPlayTimeInSeconds:CMTime = kCMTimeZero
    var currentPlayTimer:Timer!
    var currentAssetDuration:Float64 = 0
    var lastSelectedIndex:Int = 0
    var lastInsertedTime:CMTime = kCMTimeZero
    var imagePickerViewController:UIImagePickerController!
    
    var asset:AVAsset = AVAsset.init(url: Bundle.main.url(forResource: "test", withExtension: "mp4")!)
    var mutableComposition:AVMutableComposition = AVMutableComposition()
    
    var exporter:AVAssetExportSession! = nil
    
    var started:Bool = true
    
    var previousFrameRelativeStartTime:Float64!
    var previousFrameTime:CFTimeInterval!
    var currentMediaTime:CFTimeInterval!
    var currentInterval:CFTimeInterval!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.scrubberView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.exportButton)
        self.view.addSubview(self.progressView)
        self.view.addSubview(self.playerView)
        self.view.addSubview(self.previewFinalVideoView)
        self.view.addSubview(self.cameraScrubberPreviewView)
        
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
        
        let secondProgressBarContainerView:UIView = UIView(frame: .zero)
        secondProgressBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        secondProgressBarContainerView.addSubview(self.secondProgressBar)
        secondProgressBarContainerView.isHidden = true
        
        self.view.addSubview(secondProgressBarContainerView)
        
        self.secondProgressBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.secondProgressBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
        self.secondProgressBar.leftAnchor.constraint(equalTo: secondProgressBarContainerView.leftAnchor).isActive = true
        self.secondProgressBar.rightAnchor.constraint(equalTo: secondProgressBarContainerView.rightAnchor).isActive = true
        self.secondProgressBar.centerYAnchor.constraint(equalTo: secondProgressBarContainerView.centerYAnchor).isActive = true
        
        secondProgressBarContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        secondProgressBarContainerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        secondProgressBarContainerView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        secondProgressBarContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.cameraView.bottomAnchor.constraint(equalTo: self.secondProgressBar.topAnchor).isActive = true
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
        
        self.cameraScrubberPreviewView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraScrubberPreviewView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.cameraScrubberPreviewView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.cameraScrubberPreviewView.isHidden = true
        
        self.cameraScrubberPreviewConstraint = self.cameraScrubberPreviewView.widthAnchor.constraint(equalToConstant: 50)
        self.cameraScrubberPreviewConstraint.isActive = true

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
    
    var path:UIBezierPath!
    var i:Int = 0
    
    func drawLineFromPointToPoint(startX: Int, toEndingX endX: Int, startingY startY: Int, toEndingY endY: Int, ofColor lineColor: UIColor, widthOfLine lineWidth: CGFloat, inView view: UIView) {
    
        if (self.path == nil ) {
            self.path = UIBezierPath()
            
        }
        
        self.path.addLine(to: CGPoint(x: endX, y: endY))
        self.path.move(to: CGPoint(x: startX, y: startY))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
        
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        self.view.layer.addSublayer(shapeLayer)
    }
    
    func export(composition: AVMutableComposition) throws {
        let videoCompositonTrack:AVMutableCompositionTrack = composition.tracks(withMediaType: AVMediaTypeVideo).last!
        videoCompositonTrack.preferredTransform = CGAffineTransform(rotationAngle:  CGFloat(Measurement(value: 90, unit: UnitAngle.degrees).converted(to: .radians).value))
        
        self.exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        
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
                    
                    self.exportButton.resetExportButton()
                    self.resetButtonWasTapped()
                    self.mutableComposition = AVMutableComposition()
                    self.lastSelectedIndex = 0
                    self.lastInsertedTime = kCMTimeZero
                }
                else {
                    print(self.exporter.error?.localizedDescription)
                    //The requested URL was not found on this server.
                }
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeEdit(index: Int) {
        self.currentMediaTime = CACurrentMediaTime()
        
        if (self.started) {
            self.previousFrameTime = self.currentMediaTime
            self.started = false
        } else {
            self.previousFrameRelativeStartTime = Float64(TIMES[index]!)
            self.currentInterval = self.currentMediaTime - self.previousFrameTime
            
            let maxDurationInterval:Float64 = self.currentAssetDuration - self.previousFrameRelativeStartTime
            let durationInterval:CMTime = CMTimeMakeWithSeconds(min(self.currentInterval, maxDurationInterval), 600)
            
            let timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(Float64(self.previousFrameRelativeStartTime), 600), durationInterval)
            
            do {
                print(timeRange)
                try mutableComposition.insertTimeRange(timeRange, of: self.asset, at: self.lastInsertedTime)
                self.lastInsertedTime = CMTimeAdd(self.lastInsertedTime, timeRange.duration)
            } catch {
                print("something fucked up")
            }
        }
    }
}

extension ViewController : PlayButtonViewDelegate {
    func playButtonWasTapped(index: Int) {
        self.scrubberView.blowUpSliceAt(index: index)
        self.progressView.updateProgress(index: index)

        self.storeEdit(index: index)

        self.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 600),
                                     toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        self.playerView.player?.play()
        
        self.previousFrameTime = self.currentMediaTime
        self.lastSelectedIndex = index
    }
    
    func presentImagePickerViewController() {
        self.imagePickerViewController = UIImagePickerController()
        self.imagePickerViewController.delegate = self
        self.imagePickerViewController.sourceType = .savedPhotosAlbum
        self.imagePickerViewController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        
        self.present(self.imagePickerViewController, animated: false) {
            
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        self.asset = AVAsset(url: videoURL as URL)
        
        self.imagePickerViewController.dismiss(animated: true) { 
            self.view.setNeedsLayout()
        }

        self.playerView.isHidden = false
        self.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        self.cameraScrubberPreviewView.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        
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

extension ViewController : ExportViewDelegate {

    func exportButtonWasTapped() {
        print("exporting")
        
        self.checkPhotoLibraryPermission()
        do {
            self.storeEdit(index: lastSelectedIndex) // stores final edit
            
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
    func draggingHasBegun() {
        self.cameraScrubberPreviewView.isHidden = false
    }
    
    func sliceWasMovedTo(index: Int, time: Int, distance: Int) {
        TIMES[index] = Double(time)*0.01
        
        self.cameraScrubberPreviewView.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 60),
                                     toleranceBefore: CMTimeMake(1, 60),
                                     toleranceAfter: CMTimeMake(1, 60))
        
        self.cameraScrubberPreviewConstraint.constant = 20 + CGFloat(distance)
    }
    
    func draggingHasEnded() {
        self.cameraScrubberPreviewView.isHidden = true
    }
}

extension ViewController : CameraViewDelegate {
    
    func recordingHasBegun() {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = YES;
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    }
    
    func recordButtonPressed() {
        self.presentImagePickerViewController()
    }
    
    func recordingHasStoppedWithLength(time: Int) {
        
    }
}
