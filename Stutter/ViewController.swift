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
import CameraManager
import SwiftyCam
import SwiftyButton
//import RevealingSplashView
import EasyTipView
import AMPopTip
import Gecco
import PKHUD
import ElasticTransition
import LLSpinner

let WIDTH_CONSTANT = CGFloat(10.0)

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
    
    let cameraScrubberPreviewView:CameraScrubberPreviewView = CameraScrubberPreviewView(frame: CGRect.zero)
    
    let secondProgressBar:SegmentedProgressBar = SegmentedProgressBar(numberOfSegments: 5, duration: 5)
    
    let dazzleController:DazTouchController = DazTouchController()
    let fireController:DazFireController = DazFireController()
    
    var cameraScrubberPreviewConstraint:NSLayoutConstraint!
    
    var currentPlayTimeInSeconds:CMTime = kCMTimeZero
    var currentPlayTimer:Timer!
    var currentAssetDuration:Float64 = 0
    var lastSelectedIndex:Int = 0
    var lastInsertedTime:CMTime = kCMTimeZero
    
    var asset:AVAsset = AVAsset.init(url: Bundle.main.url(forResource: "test", withExtension: "mp4")!)
    var mutableComposition:AVMutableComposition = AVMutableComposition()
    
    var exporter:AVAssetExportSession! = nil
    
    var started:Bool = true
    
    var previousFrameRelativeStartTime:Float64!
    var previousFrameTime:CFTimeInterval!
    var currentMediaTime:CFTimeInterval!
    var currentInterval:CFTimeInterval!

    var recordingCounter:UILabel!
    
    var audioPlayer:AVAudioPlayer!
    
    var transition:ElasticTransition = {
        var transition = ElasticTransition()
        transition.edge = .right
        transition.sticky = false
        transition.stiffness = 0.5
        transition.radiusFactor = 1
        transition.damping = 0.5
        transition.showShadow = true
        transition.shadowRadius = 50
        transition.shadowColor = UIColor.black
        transition.transformType = .translatePush

        return transition
    }()
    
    var leftTransition:ElasticTransition = {
        var transition = ElasticTransition()
        transition.edge = .left
        transition.sticky = false
        transition.stiffness = 0.5
        transition.radiusFactor = 1
        transition.damping = 0.5
        transition.showShadow = true
        transition.shadowRadius = 50
        transition.shadowColor = UIColor.black
        transition.transformType = .translatePull
        
        return transition
    }()
    
    var TIMES = [0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0]
    var originalVolume:Float = 0
    let cameraViewController:CameraViewController = {
        var cameraViewController = CameraViewController()
        cameraViewController.videoGravity = .resizeAspectFill
        return cameraViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.addSubview(self.playerView)
        self.view.addSubview(self.scrubberView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.exportButton)

        self.view.addSubview(self.cameraScrubberPreviewView)

        self.exportButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.exportButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.exportButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.exportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        self.playButtonsView.bottomAnchor.constraint(equalTo: self.exportButton.topAnchor).isActive = true
        self.playButtonsView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playButtonsView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.playButtonsView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            self.playButtonsView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        self.scrubberView.bottomAnchor.constraint(equalTo: self.playButtonsView.topAnchor).isActive = true
        self.scrubberView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrubberView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrubberView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        self.playerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
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
        
        self.cameraScrubberPreviewView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraScrubberPreviewView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.cameraScrubberPreviewView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.cameraScrubberPreviewView.isHidden = true
        
        
        self.dazzleController.view.bounds = self.view.bounds
        self.fireController.view.bounds = self.view.bounds
        
        self.view.insertSubview(self.dazzleController.view, aboveSubview: self.playerView)
        self.view.insertSubview(self.fireController.view, aboveSubview: self.dazzleController.view)
        
        self.cameraScrubberPreviewConstraint = self.cameraScrubberPreviewView.widthAnchor.constraint(equalToConstant: 50)
        self.cameraScrubberPreviewConstraint.isActive = true

        self.scrubberView.delegate = self
        self.playButtonsView.delegate = self
        self.exportButton.delegate = self

        self.view.isUserInteractionEnabled = true
        
//        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "stars")!,
//                                                      iconInitialSize: CGSize(width: 70, height: 70),
//                                                      backgroundColor: UIColor(red:0.11, green:0.56, blue:0.95, alpha:1.0))
//        
//        //Adds the revealing splash view as a sub view
//        self.view.addSubview(revealingSplashView)
//        
//        //Starts animation
//        revealingSplashView.startAnimation(){
//            print("Completed")
//        }
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        EasyTipView.globalPreferences = preferences
    }
    
    var alreadyAppeared:Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!self.alreadyAppeared) {
            self.cameraViewController.cameraDelegate = self
            self.cameraViewController.transitioningDelegate = leftTransition
            self.cameraViewController.modalPresentationStyle = .custom
            
            self.cameraViewController.shouldUseDeviceOrientation = true
            
            self.present(self.cameraViewController, animated: true) {
                print("camera shown")
                self.alreadyAppeared = true
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    func showSpotlight() {
        let spotlightViewController = SpotlightViewController()
        self.present(spotlightViewController, animated: true, completion: nil)
        spotlightViewController.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: 100, y: 100), diameter: 100))
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
                    
                    self.playerView.player?.pause()
                    self.playerView.player = nil
                    self.playerView.isHidden = true
                    
                    self.scrubberView.clearThumbnails()
                    
                    self.mutableComposition = AVMutableComposition()
                    self.lastSelectedIndex = 0
                    self.lastInsertedTime = kCMTimeZero
                    
                    let viewController = LoadingViewController()
                    viewController.transitioningDelegate = self.transition
                    viewController.modalPresentationStyle = .custom
                    
                    self.present(viewController, animated: true, completion: {
                        LLSpinner.stop()
                    })
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
        
        let distance = self.scrubberView.getSlicePosition(index: index)
        let y =  self.scrubberView.frame.origin.y + self.scrubberView.frame.size.height/2
        self.dazzleController.touch(atPosition: CGPoint(x: distance, y:y))
        

        self.storeEdit(index: index)

        self.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 600),
                                     toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        self.playerView.player?.play()
        
        self.previousFrameTime = self.currentMediaTime
        self.lastSelectedIndex = index
    }
    
    func badgedEarned(badge: Int, index: Int) {
        let distance = self.scrubberView.getSlicePosition(index: index)
        let y =  self.scrubberView.frame.origin.y + self.scrubberView.frame.size.height/2
        
        self.fireController.controlFireLocation(CGPoint(x: distance, y:self.scrubberView.frame.origin.y), withBadge: badge)
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func processAsset() {
        var times:[NSValue] = []
        
        // 320 / 30
        
        var i:Int64 = 0
        while(i < 10) {
            let interval:Int64 = self.asset.duration.value/Int64(10)
            times.append(NSValue(time: CMTimeMake(interval * i, self.asset.duration.timescale)))
            i += 1
        }
        
        var images:[UIImage] = []
        
        let assetGenerator:AVAssetImageGenerator = AVAssetImageGenerator(asset: self.asset)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            let image:UIImage = UIImage(cgImage: image!)
            DispatchQueue.main.sync {
                self.scrubberView.addImage(image: image)
                
                if ((self.playerView.player?.rate)! > Float(0)) {
                    self.playerView.player?.pause()
                    self.playerView.player?.volume = self.originalVolume
                    self.playerView.player?.seek(to: kCMTimeZero)
                    self.playerView.isHidden = false
                }
            }
        }
        
        self.playerView.isHidden = false
        self.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        self.cameraScrubberPreviewView.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        
        var time:Float64!
        
        let audioTrack:AVAssetTrack = self.asset.tracks(withMediaCharacteristic: AVMediaCharacteristicAudible)[0]
        
        let desc = audioTrack.formatDescriptions[0] as! CMAudioFormatDescription
        let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
        
        do {
            self.audioPlayer = try? AVAudioPlayer(contentsOf: (self.asset as! AVURLAsset).url)
        } catch {
            
        }
        
        self.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            switch(self.asset.statusOfValue(forKey: "duration", error: nil)) {
            case AVKeyValueStatus.loaded:
                time = CMTimeGetSeconds(self.asset.duration)
                self.scrubberView.length = Int(floor(time * 100))
                self.scrubberView.resetTimes()
                self.currentAssetDuration = time
                
                break
            default:
                break
            }
        }
        
        self.playerView.isHidden = true
        self.originalVolume = (self.playerView.player?.volume)!
        
        self.playerView.player?.volume = 0
        self.playerView.player?.play()
        
        LLSpinner.stop()
    }
}

extension ViewController : ExportViewDelegate {

    func exportButtonWasTapped() {
        print("exporting")
        
        self.checkPhotoLibraryPermission()

        self.storeEdit(index: lastSelectedIndex) // stores final edit
        
        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.2)) {
            
        }
        
        do {
            try self.export(composition: self.mutableComposition)
        } catch {
            
        }
    }
    
    func playButtonWasTapped() {
        print("play new one")
    }
    
    func resetButtonWasTapped() {
        print("Reseting scrubs")
        
        self.present(self.cameraViewController, animated: true) {
            print("camera shown")
            self.alreadyAppeared = true
            
            self.playerView.player?.pause()
            self.playerView.player = nil
            self.playerView.isHidden = true
            
            self.scrubberView.clearThumbnails()
        }
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


extension ViewController : SwiftyCamViewControllerDelegate {
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Called when takePhoto() is called or if a SwiftyCamButton initiates a tap gesture
        // Returns a UIImage captured from the current session
        print("photo")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        print("started recording")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
        print("finished recording")
        
        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.2)) {
            
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        print("did finish recording")
        
        self.asset = AVAsset(url: url)
        self.processAsset()
        
        AudioExporter.getAudioFromVideo(self.asset) { (exportSession) in
            let url:URL = (exportSession?.outputURL)!
            
            let file = try! AVAudioFile(forReading: url)
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
            print(file.fileFormat.channelCount)
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            try! file.read(into: buf)
            
            // this makes a copy, you might not want that
            readFile.arrayFloatValues = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Called when a user initiates a pinch gesture on the preview layer
        // Will only be called if pinchToZoomn = true
        // Returns a CGFloat of the current zoom level
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Called when user switches between cameras
        // Returns current camera selection
    }
}

