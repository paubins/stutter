//
//  ViewController.swift
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/16/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

import UIKit
import Cartography
import Player
import AVFoundation
import Photos
import ReplayKit
import LLSpinner
import DynamicButton
import SwiftyButton
import Shift
import Hue
import SwiftyCam
import MediaPlayer
import AVKit
import Presentr
import JTFadingInfoView

protocol LoaderViewControllerDelegate {
    func mediaChosen(url: URL)
}

class LoaderViewController: UIViewController {

    var delegate:LoaderViewControllerDelegate!
    var mainViewController:ViewController!
    
    var infoView:JTFadingInfoView = {
        let view:JTFadingInfoView = JTFadingInfoView(frame: CGRect(x: 150, y: 200, width: 150, height: 50), label: "Sucessfully exported!")
        return view
    }()
    
    var buttonsBackgroundView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors([UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7")])
        return v
    }()
    
    var loadNewVideoView:PressableButton = {
        let newView:PressableButton = PressableButton()
        newView.colors = .init(button: UIColor(hex: "#F0B0B7"), shadow: UIColor(hex: "#BD888E"))
        newView.shadowHeight = 15
        newView.cornerRadius = 30
        newView.backgroundColor = .clear
        newView.titleLabel?.font = UIFont.init(name: "VarelaRound-Regular", size: 20)
        newView.titleLabel?.font = newView.titleLabel?.font.withSize(20)
        newView.setTitleColor(.black, for: .normal)
        return newView
    }()
    
    var takeNewVideoView:PressableButton = {
        let newView:PressableButton = PressableButton()
        newView.colors = .init(button: UIColor(hex: "#F3C74F"), shadow: UIColor(hex: "#C09C3B"))
        newView.shadowHeight = 15
        newView.cornerRadius = 30
        newView.backgroundColor = .clear
        newView.titleLabel?.font = UIFont(name: "VarelaRound-Regular", size: 20)
        newView.titleLabel?.font = newView.titleLabel?.font.withSize(20)
        newView.setTitleColor(.black, for: .normal)
        return newView
    }()
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.20)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 0))
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundColor = .green
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        return customPresenter
    }()
    
    var picker:UIImagePickerController!
    var picker2:UIImagePickerController!
    
    var cameraViewController:CameraViewController!
    var asset:AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraViewController = CameraViewController()
        self.cameraViewController.cameraDelegate = self
            
        self.view.addSubview(self.buttonsBackgroundView)
        
        self.view.addSubview(self.loadNewVideoView)
        self.view.addSubview(self.takeNewVideoView)
        
        self.loadNewVideoView.setTitle("Load", for: .normal)
        self.takeNewVideoView.setTitle("Open", for: .normal)
        
        self.loadNewVideoView.addTarget(self, action: #selector(loadNewVideo), for: UIControlEvents.touchUpInside)
        self.takeNewVideoView.addTarget(self, action: #selector(takeNewVideo), for: UIControlEvents.touchUpInside)
            
        
        constrain(self.buttonsBackgroundView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
            
        constrain(loadNewVideoView, takeNewVideoView) { (view, view1) in
            view.top == (view.superview?.top)! + 30
            view.left == (view.superview?.left)! + 20
            view.right == (view.superview?.right)! - 20
            view.bottom == (view1.top) - 20
            
            view.height >= 60
            
            view1.left == (view.superview?.left)! + 20
            view1.right == (view.superview?.right)! - 20
            view1.bottom == (view.superview?.bottom)! - 20
            
            view1.height == view.height
        }
        
        self.picker = UIImagePickerController()
        
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.cameraDevice = .front
        picker.delegate = self
        
        self.picker2 = UIImagePickerController()
        
        picker2.allowsEditing = true
        picker2.sourceType = .photoLibrary
        picker2.mediaTypes = ["public.movie"]
        picker2.delegate = self
        
        
        // set animation duration
        self.buttonsBackgroundView.animationDuration(3.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // start animation
        self.buttonsBackgroundView.startTimedAnimation()
    }

    func takeNewVideo(sender: UIButton) {
        self.present(self.picker, animated: true) {
            print("presented")
        }
    }
    
    func loadNewVideo(sender: UIButton) {
        self.present(picker2, animated: true) {
            print("presented")
        }
    }
    
    var composition:AVMutableComposition!
    var url:URL!
}

extension LoaderViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked media")
        
        if (self.picker == picker) {
            self.url = info[UIImagePickerControllerMediaURL] as! URL
        } else {
            self.url = info[UIImagePickerControllerMediaURL] as! URL
        }
        
        self.loadAsset(url: self.url)
    }
    
    func loadAsset(url: URL) {
        self.asset = AVAsset(url: url)
        
        self.mainViewController = ViewController(url: url)
        self.mainViewController.delegate = self
        
        self.composition = AVMutableComposition()
        
        var videoTrack2: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0)
        var audioTrack2: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
        
        var videoAssetTracks2: [Any] = self.asset.tracks(withMediaType: AVMediaTypeVideo)
        var audioAssetTracks2: [Any] = self.asset.tracks(withMediaType: AVMediaTypeAudio)
        
        var videoAssetTrack2 = (videoAssetTracks2.count > 0 ? videoAssetTracks2[0] as? AVAssetTrack : nil)
        try? videoTrack2?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), of: videoAssetTrack2!, at: kCMTimeZero)
        
        var audioAssetTrack2 = (audioAssetTracks2.count > 0 ? audioAssetTracks2[0] as? AVAssetTrack : nil)
        try? audioTrack2?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, self.asset.duration), of: audioAssetTrack2!, at: kCMTimeZero)
        
        AudioExporter.getAudioFromVideo(self.asset, composition: composition) { (exportSession) in
            let url:URL = (exportSession?.outputURL)!
            
            DispatchQueue.main.sync {
                self.mainViewController.asset = self.asset
                self.mainViewController.processAsset()
                self.mainViewController.scrubberView.waveformView.audioURL = url
                
                self.dismiss(animated: true) {
                    print("dismissed")
                    
                }
                
                self.present(self.mainViewController, animated: true, completion: {
                    print("presented main viewcontroller")
                })
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        //        self.tabBarController.sidebar.selectItemAtIndex(0)
        
        self.dismiss(animated: true) {
            print("dismissed")
        }
    }
}

extension LoaderViewController : ViewControllerDelegate {
    func displayComposition(composition: AVMutableComposition) {
        print(composition)
        
        let loadingViewController:LoadingViewController = LoadingViewController()
        loadingViewController.videoPlayerView.player.setAsset(composition)
        loadingViewController.delegate = self
        
        self.present(loadingViewController, animated: true, completion: {
            print("presented main viewcontroller")
        })
    }
    
    func dismissedViewController() {
        self.mainViewController = nil
    }
}

extension LoaderViewController : SwiftyCamViewControllerDelegate {
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
        
        self.mainViewController = ViewController(url: url)
        self.mainViewController.delegate = self
        
        let asset = AVAsset(url: url)
        
//        AudioExporter.getAudioFromVideo(asset, composition: <#AVMutableComposition!#>) { (exportSession) in
//            let url:URL = (exportSession?.outputURL)!
//            
//            DispatchQueue.main.sync {
//                self.mainViewController.asset = asset
//                self.mainViewController.processAsset()
//                self.mainViewController.scrubberView.waveformView.audioURL = url
//                
//                self.present(self.mainViewController, animated: true, completion: { 
//                    print("presented main viewcontroller")
//                })
//            }
//            
//        }
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

extension LoaderViewController : LoadingViewControllerDelegate {
    func exportSucessful(controller: UIViewController) {
//        customPresentViewController(self.presenter, viewController: self, animated: true, completion: nil)
        
        self.infoView.removeFromSuperview()
        self.view.addSubview(self.infoView)
        
        constrain(self.infoView) { (view) in
            view.width == 250
            view.height == 50
//            view.bottom == (view.superview?.bottom)! - 50
            view.centerX == (view.superview?.centerX)!
            view.centerY == (view.superview?.centerY)!
        }
    }
}
