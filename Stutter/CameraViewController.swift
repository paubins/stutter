//
//  CameraViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 6/9/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import SwiftyCam
import SwiftyButton
import AVFoundation
import Beethoven
import Pitchy

class CameraViewController : SwiftyCamViewController {
    
    var buttonTimer:Timer!
    var recordButton:SDevCircleButton!
    
    var flipCameraButton:UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        var flipCameraButton = PressableButton()
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(flipCameraButton)
        
        flipCameraButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        flipCameraButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        flipCameraButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        flipCameraButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        flipCameraButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                        shadow: UIColor.black)
        flipCameraButton.shadowHeight = 10
        flipCameraButton.cornerRadius = 15
        flipCameraButton.setTitle("Flip", for: .normal)
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        
        return containerView
    }()
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        var config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
            
        return pitchEngine
    }()
    
    var button1:SDevCircleButton! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pinchToZoom = false
        self.swipeToZoom = true
        self.swipeToZoomInverted = true
        self.defaultCamera = .front
        self.videoGravity = .resizeAspectFill
        
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.button1 = SDevCircleButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        let longPressGestureRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordButtonWasTapped))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        longPressGestureRecognizer.delegate = self
        self.panGesture.delegate = self
        
        button1.addGestureRecognizer(longPressGestureRecognizer)
//        button1.addGestureRecognizer(self.panGesture)
        
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.normal)
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.selected)
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.highlighted)
        
        button1.setTitle("", for: UIControlState.normal)
        button1.setTitle("", for: UIControlState.selected)
        button1.setTitle("", for: UIControlState.highlighted)
        
        button1.backgroundColor = UIColor.red
        
        containerView.addSubview(button1)
        
        button1.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        button1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        button1.heightAnchor.constraint(equalToConstant: 80).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.recordButton = button1
        
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(self.flipCameraButton)
        
        self.flipCameraButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.flipCameraButton.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        self.flipCameraButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        self.flipCameraButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.view.addSubview(containerView)
        
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.allowBackgroundAudio = true
        self.lowLightBoost = true
        self.doubleTapCameraSwitch = true
        self.pinchToZoom = true
        
        self.cameraDelegate = self
//        self.transitioningDelegate = leftTransition
//        self.mainViewController.modalPresentationStyle = .custom
        
        self.shouldUseDeviceOrientation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pitchEngine.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pitchEngine.stop()
        self.button1.backgroundColor = UIColor.red
    }
    
    func flipCamera() {
        self.switchCamera()
    }
    
    func recordButtonWasTapped(sender: UILongPressGestureRecognizer) {
        let _:SDevCircleButton = sender.view as! SDevCircleButton
        
        if(sender.state == UIGestureRecognizerState.began) {
            self.startVideoRecording()
        } else if (sender.state == UIGestureRecognizerState.ended) {
            self.stopVideoRecording()
        }
    }

    func offsetColor(_ offsetPercentage: Double) -> UIColor {
        let color: UIColor
        
        switch abs(offsetPercentage) {
        case 0...5:
            color = UIColor(hex: "3DAFAE")
        case 6...25:
            color = UIColor(hex: "FDFFB1")
        default:
            color = UIColor(hex: "E13C6C")
        }
        
        return color
    }
}

extension CameraViewController: PitchEngineDelegate {
    
    func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch) {
        let offsetPercentage = pitch.closestOffset.percentage
        let absOffsetPercentage = abs(offsetPercentage)
        
        self.recordButton.setTitle(pitch.note.string, for: UIControlState.normal)
        
        guard absOffsetPercentage > 1.0 else {
            return
        }
        
        let color = offsetColor(offsetPercentage)
        
        if(self.isVideoRecording) {
            self.recordButton.triggerAnimateTap()
            self.recordButton.backgroundColor = color
        } else {
            self.recordButton.triggerAnimateTap()
        }
    }
    
    func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error) {
        print(error)
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below level threshold")
        self.recordButton.setTitle("", for: UIControlState.normal)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func reset() {
        
    }
}


extension CameraViewController : SwiftyCamViewControllerDelegate {
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
        
//        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.2)) {
//            
//        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        print("did finish recording")
        
        let mainViewController:ViewController = ViewController()
        let asset = AVAsset(url: url)
        
        AudioExporter.getAudioFromVideo(asset) { (exportSession) in
            let url:URL = (exportSession?.outputURL)!
            
            DispatchQueue.main.sync {
                mainViewController.asset = asset
                mainViewController.processAsset()
                mainViewController.scrubberView.waveformView.audioURL = url
                self.navigationController?.pushViewController(mainViewController, animated: true)
            }
            
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

