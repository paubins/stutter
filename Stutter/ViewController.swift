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
import SwiftyCam
import SwiftyButton
import ElasticTransition
import LLSpinner
import FDWaveformView
import VideoViewController
import DynamicButton
import Player
import Device
import Cartography
import Shift
import FCAlertView
import AVKit
import SwiftyTimer
import KDCircularProgress
import FontAwesomeKit

extension UIView {
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
    }
}

let WIDTH_CONSTANT = CGFloat(10.0)

protocol ViewControllerDelegate {
    func displayComposition(composition: AVMutableComposition)
    func dismissedViewController()
}

class ViewController: UIViewController {
    var scrubberView:ScrubberView = ScrubberView(frame: CGRect.zero)
    let playButtonsView:PlayButtonsView = PlayButtonsView(frame: CGRect.zero)
    
    var player:Player = Player()
    
    var loaderViewController:LoaderViewController = LoaderViewController()
    
    var delegate:ViewControllerDelegate!
    
    let menuViewController:MenuViewController = MenuViewController()
    
    let recordButtonView:RecordButtonsView = RecordButtonsView(frame: CGRect.zero)
    
    var bornCoordinateSpace:UICoordinateSpace!
    
    let loadFromCameraButton:UIView = {
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
        
        let icon = FAKFontAwesome.cameraRetroIcon(withSize: 40)
        let playStopBackButton:UIButton = UIButton()
        playStopBackButton.setImage(icon?.image(with: CGSize(width: 40, height: 40)), for: .normal)
        playStopBackButton.addTarget(self, action: #selector(loadFromCamera), for: .touchUpInside)
        
        containerView.addSubview(playStopBackButton)
        
        constrain(playStopBackButton) { (view) in
            view.width == 30
            view.height == 30
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        return containerView
    }()
    
    let loadFromLibraryButton:UIView = {
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
        
        let icon = FAKFontAwesome.filePhotoOIcon(withSize: 40)
        let playStopBackButton:UIButton = UIButton()
        playStopBackButton.setImage(icon?.image(with: CGSize(width: 40, height: 40)), for: .normal)
        playStopBackButton.addTarget(self, action: #selector(loadFromLibrary), for: .touchUpInside)
        
        containerView.addSubview(playStopBackButton)
        
        constrain(playStopBackButton) { (view) in
            view.width == 30
            view.height == 30
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        return containerView
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
        
        let shareIcon = FAKFontAwesome.shareIcon(withSize: 40)
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
        
        return containerView
    }()
    
    let bezierView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    let spacerView:UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        progress.isHidden = true
        progress.set(colors: UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7"))
        
        return progress
    }()
    
    let cameraScrubberPreviewView:CameraScrubberPreviewView = CameraScrubberPreviewView(frame: CGRect.zero)
    
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

    var path:UIBezierPath!
    var i:Int = 0
    
    var alreadyAppeared:Bool = false
    
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
    
    var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors([UIColor(hex: "#40BAB3"),
                     UIColor(hex: "#F3C74F"),
                     UIColor(hex: "#0081C6"),
                     UIColor(hex: "#F0B0B7")])
        return v
    }()
    
    var bezierViewControllers:[BezierViewController] = []
    
    var TIMES = [0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0]
    var originalVolume:Float = 0
    
    var progressTimer:Timer!
    
    func goBack() {
        self.dismiss(animated: true) { 
            print("dismissed")
            self.delegate.dismissedViewController()
        }
    }
    
    func loadFromCamera(sender: DynamicButton) {
        self.present(self.loaderViewController.picker, animated: true) {
            print("load from library")
        }
    }
    
    func loadFromLibrary(sender: DynamicButton) {
        self.present(self.loaderViewController.picker2, animated: true) {
            print("load from camera")
        }
    }
    
    func saveVideo(sender: UIButton) {
        self.player.stop()
        
        let loadingViewController:LoadingViewController = LoadingViewController()
        
        let assetVideoTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).last!
        let videoCompositonTrack:AVMutableCompositionTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).last!
        videoCompositonTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        let exportSession:AVAssetExportSession = try! loadingViewController.export(asset: self.mutableComposition)
        self.progress.isHidden = false
        
        self.progressTimer = Timer.every(1.second) {
            if (exportSession.progress == 1.0) {
                let activityController:UIActivityViewController = UIActivityViewController(activityItems: [exportSession.outputURL], applicationActivities: nil)
                activityController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                    if(completed) {
                        let alert:FCAlertView = FCAlertView()
                        alert.makeAlertTypeSuccess()
                        alert.showAlert(inView: self,
                                        withTitle: "Saved!",
                                        withSubtitle: "Your video saved!",
                                        withCustomImage: nil,
                                        withDoneButtonTitle: "👌",
                                        andButtons: nil)

                        alert.colorScheme = UIColor(hex: "#8C9AFF")
                        
                        self.progress.isHidden = true
                        
                        self.processAsset()
                    }
                }
                
                
                self.present(activityController, animated: true) {
                    print("presented share controller")
                }
                
                self.progressTimer.invalidate()
                self.progressTimer = nil
                
            } else {
                self.progress.progress = Double(exportSession.progress)
            }
        }
    }
    
    init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.player.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bornCoordinateSpace = UIScreen.main.coordinateSpace
        
        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.backgroundShiftView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.player.playbackDelegate = self
        self.player.view.frame = self.view.bounds
        self.player.fillMode = AVLayerVideoGravityResizeAspect
        self.player.playbackLoops = true
        self.player.view.backgroundColor = .clear
        
        self.addChildViewController(self.player)
        
        self.player.didMove(toParentViewController: self)
        
        self.view.addSubview(self.player.view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.addSubview(self.menuViewController.view)
        self.view.addSubview(self.scrubberView)
        self.view.addSubview(self.bezierView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.progress)
        
        self.menuViewController.view.isHidden = true

        self.view.addSubview(self.cameraScrubberPreviewView)
    
        self.view.addSubview(self.spacerView)
        
        self.view.addSubview(self.loadFromCameraButton)
        self.view.addSubview(self.loadFromLibraryButton)
        self.view.addSubview(self.saveShareButton)
        self.view.addSubview(self.recordButtonView)
        
        self.recordButtonView.delegate = self
        
        constrain(self.backgroundShiftView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.loadFromCameraButton, self.loadFromLibraryButton, self.saveShareButton) { (view, view1, view2) in
            view.right == view.superview!.right - 15
            view.top == view.superview!.top + 40
            view.height == 60
            view.width == 60
            
            view1.right == view1.superview!.right - 15
            view1.top == view.bottom + 15
            view1.height == 60
            view1.width == 60
            
            view2.right == view2.superview!.right - 15
            view2.top == view1.bottom + 15
            view2.height == 60
            view2.width == 60
            
        }

        self.bezierView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.bezierView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bezierView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bezierView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        
        self.playButtonsView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playButtonsView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.playButtonsView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            self.playButtonsView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        self.spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        self.spacerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.spacerView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.spacerView.topAnchor.constraint(equalTo: self.playButtonsView.bottomAnchor).isActive = true
        
        self.recordButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.recordButtonView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.recordButtonView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.recordButtonView.bottomAnchor.constraint(equalTo: self.playButtonsView.topAnchor).isActive = true
        
        self.menuViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.menuViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.menuViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.menuViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        self.scrubberView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//        self.scrubberView.topAnchor.constraint(equalTo: self.playButtonsView.bottomAnchor).isActive = true
        self.scrubberView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.scrubberView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.scrubberView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        constrain(self.player.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.progress) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
            view.height == 50
            view.width == 50
        }
        
        self.cameraScrubberPreviewView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraScrubberPreviewView.bottomAnchor.constraint(equalTo: self.recordButtonView.topAnchor).isActive = true
        self.cameraScrubberPreviewView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.cameraScrubberPreviewView.isHidden = true
        
        self.dazzleController.view.bounds = self.view.bounds
        self.fireController.view.bounds = self.view.bounds
        
        self.view.insertSubview(self.dazzleController.view, aboveSubview: self.player.view)
//        self.view.insertSubview(self.fireController.view, aboveSubview: self.dazzleController.view)
        
        self.cameraScrubberPreviewConstraint = self.cameraScrubberPreviewView.widthAnchor.constraint(equalToConstant: 50)
        self.cameraScrubberPreviewConstraint.isActive = true

        self.scrubberView.delegate = self
        self.playButtonsView.delegate = self

        self.view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
    
        // set animation duration
        self.backgroundShiftView.animationDuration(3.0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!self.alreadyAppeared) {
            self.backgroundShiftView.startTimedAnimation()
            self.alreadyAppeared = true
            
            for index in 0..<5 {
                let slicePositionX:CGFloat = self.scrubberView.getSlicePosition(index: index)
                let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
                
                let viewController:BezierViewController = BezierViewController(points: self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY), with: Constant.COLORS[index])
                self.bezierViewControllers.append(viewController)
                self.bezierView.addSubview(viewController.view)
                
                self.sliceWasMovedTo(index: index, time: Int(self.currentAssetDuration/Float64(3)), distance: Int(slicePositionX))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.loadFromLibraryButton.makeCircular()
        self.loadFromCameraButton.makeCircular()
        self.saveShareButton.makeCircular()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("disappeared")
        
        self.reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.dch_checkDeallocation()
        
    }
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.location(in: self.view).x < UIScreen.main.bounds.width/4) {
            self.player.playFromBeginning()
        } else {
            self.player.stop()
        }
        
    }
    
    func screenSize() {
        /*** Display the device screen size ***/
        switch Device.size() {
        case .screen3_5Inch:
            print("It's a 3.5 inch screen")
            
        case .screen4Inch:
            print("It's a 4 inch screen")
            
        case .screen4_7Inch:
            print("It's a 4.7 inch screen")
            
        case .screen5_5Inch:
            print("It's a 5.5 inch screen")
            if (UIScreen.main.scale == 3.0) {
                
            } else {
                
            }

        case .screen7_9Inch:
            print("It's a 7.9 inch screen")
            
        case .screen9_7Inch:
            print("It's a 9.7 inch screen")
            
            
        case .screen12_9Inch:
            print("It's a 12.9 inch screen")
            
        default:
            print("Unknown size")
        }
    }

    func orientationChange(notification: Notification) {
        self.scrubberView.setNeedsDisplay()
        
        for (i, bezierViewController) in  self.bezierViewControllers.enumerated() {
            let slicePositionX:CGFloat = self.recordButtonView.getSlicePosition(index: i)
            let slicePositionY:CGFloat = self.scrubberView.frame.origin.y

            bezierViewController.points = self.generatePoints(index: i, slicePositionX: slicePositionX,
                                                              slicePositionY: slicePositionY)
            
            bezierViewController.pointsChanged()
        }
    }
    
    func getSlicePositionBasedOnTime(index: Int) -> CGFloat {
        if TIMES[index] == 0.01 {
            self.recordButtonView.getSlicePosition(index: index)
        }
        
        let currentSlicePosition = self.recordButtonView.getSlicePosition(index: index)
        let currentTime:Int = Int(CGFloat(TIMES[index]!/0.01)*CGFloat(3))
        
        return (currentSlicePosition/CGFloat(currentTime)) * UIScreen.main.bounds.size.width
    }
    
    func generatePoints(index: Int, slicePositionX: CGFloat, slicePositionY: CGFloat) -> [NSValue] {
        var points:[NSValue] = []
        let buttonHeight = self.playButtonsView.button0.frame.height
        
        // original slice position
        points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                               y: slicePositionY)))
        
        // just above the slice position
        points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                               y: slicePositionY - 10)))
        
        // just below the play buttons
        points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                               y: self.playButtonsView.buttonCenter(atIndex: index).y + buttonHeight/2 + 10)))
        
        // the middle of the play button position
        points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                               y: self.playButtonsView.buttonCenter(atIndex: index).y)))
        
        // just above the play button position
        
        if (Device.type() == .iPad) {
            points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                                   y: self.playButtonsView.buttonCenter(atIndex: index).y - 75)))
        } else {
            points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                                   y: self.playButtonsView.buttonCenter(atIndex: index).y - 50)))
        }
        
        var offset = CGFloat(index*10)
        if (index == 0) {
            offset = CGFloat((index+1) * 10)
        } else {
            offset = CGFloat(index*10)
        }
        
        if (Device.type() == .iPad) {
            let origin:CGPoint = self.recordButtonView.slices[index].frame.origin
            let newOrigin:CGPoint = CGPoint(x: origin.x + 10, y: origin.y - 15)
            let point:CGPoint = self.view.convert(newOrigin, from: self.recordButtonView.slices[index])
            
            points.append(NSValue(cgPoint: point))
        } else {
            points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                                   y: slicePositionY - 100 + offset)))
        }
        
            
        
        return points
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
        
        view.layer.addSublayer(shapeLayer)
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
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        self.exporter.outputFileType = AVFileTypeMPEG4
        self.exporter.outputURL = fileUrl
        
        self.exporter.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                if self.exporter.status == AVAssetExportSessionStatus.completed {
                    UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, nil, nil)
                    print("Success")
                    
                    self.player.stop()
                    
                    self.scrubberView.clearThumbnails()
                    
                    self.mutableComposition = AVMutableComposition()
                    self.lastSelectedIndex = 0
                    self.lastInsertedTime = kCMTimeZero
                    
                    LLSpinner.stop()
                    
                    self.dismiss(animated: true, completion: { 
                        print("completed")
                        self.delegate.dismissedViewController()
                    })
                }
                else {
                    print(self.exporter.error?.localizedDescription ?? "error")
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
        
        self.scrubberView.waveformView.progressSamples = Int((distance + 10)/self.scrubberView.frame.width * CGFloat(self.scrubberView.waveformView.totalSamples))
        
        _ =  self.scrubberView.frame.origin.y + self.scrubberView.frame.size.height/2
        
        self.dazzleController.touch(atPosition: CGPoint(x: self.recordButtonView.getSlicePosition(index: index) + 10, y: self.recordButtonView.frame.origin.y + CGFloat(index*10)))
        
        self.storeEdit(index: index)
        
        self.player.seekToTime(to: CMTimeMakeWithSeconds(TIMES[index]!, 600), toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        
        self.player.playFromCurrentTime()
        
        self.previousFrameTime = self.currentMediaTime
        self.lastSelectedIndex = index
    }
    
    func badgedEarned(badge: Int, index: Int) {
        _ = self.scrubberView.getSlicePosition(index: index)
        _ =  self.scrubberView.frame.origin.y + self.scrubberView.frame.size.height/2
        
//        self.fireController.controlFireLocation(CGPoint(x: distance, y:self.scrubberView.frame.origin.y), withBadge: badge)
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
        
        var _:[UIImage] = []
        
        let assetGenerator:AVAssetImageGenerator = AVAssetImageGenerator(asset: self.asset)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            let image:UIImage = UIImage(cgImage: image!)
            DispatchQueue.main.sync {
                self.scrubberView.addImage(image: image)
                

            }
        }
        
        self.player.url = (self.asset as! AVURLAsset).url
        
        self.cameraScrubberPreviewView.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
        
        var time:Float64!
        
        let audioTrack:AVAssetTrack = self.asset.tracks(withMediaCharacteristic: AVMediaCharacteristicAudible)[0]
        
        let desc = audioTrack.formatDescriptions[0] as! CMAudioFormatDescription
        _ = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: (self.asset as! AVURLAsset).url)
        } catch {
            
        }
        
        self.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            switch(self.asset.statusOfValue(forKey: "duration", error: nil)) {
            case AVKeyValueStatus.loaded:
                time = CMTimeGetSeconds(self.asset.duration)
                self.scrubberView.length = Int(floor(time * 100))
                self.recordButtonView.length = Int(floor(time * 100))
                
                self.scrubberView.resetTimes()
                self.currentAssetDuration = time
                
                break
            default:
                break
            }
        }
        

        self.player.playFromBeginning()
        
        LLSpinner.stop()
    }
    
    func reset() {
        self.scrubberView.removeAllImages()
    }
}

extension ViewController : ScrubberViewDelegate {
    func draggingHasBegun() {
        self.cameraScrubberPreviewView.isHidden = false
    }
    
    func sliceWasMovedTo(index: Int, time: Int, distance: Int) {
        TIMES[index] = Double(time)*0.01
    
        let slicePositionX:CGFloat = self.scrubberView.getSlicePosition(index: index)
        let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
        
        self.bezierViewControllers[index].points = self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY)
        
        self.bezierViewControllers[index].pointsChanged()
        
        self.recordButtonView.updateFlipper(index: index, distance: CGFloat(distance))
        
        self.cameraScrubberPreviewView.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 60),
                                     toleranceBefore: CMTimeMake(1, 60),
                                     toleranceAfter: CMTimeMake(1, 60))
        
        
        self.cameraScrubberPreviewConstraint.constant = 20 + CGFloat(distance)
    }
    
    func draggingHasEnded() {
        self.cameraScrubberPreviewView.isHidden = true
    }

}

extension ViewController : RecordButtonsViewDelegate {
    func recordButtonDraggingHasBegun() {
        self.cameraScrubberPreviewView.isHidden = false
    }
    
    func recordButtonSliceWasMovedTo(index: Int, time: Int, distance: Int) {
        TIMES[index] = Double(time)*0.01
        print("go")
        
        let slicePositionX:CGFloat = self.recordButtonView.getSlicePosition(index: index)
        let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
        
        self.bezierViewControllers[index].points = self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY)
        
        self.bezierViewControllers[index].pointsChanged()
        
        self.scrubberView.updateFlipper(index: index, distance: CGFloat(distance))
        
        self.cameraScrubberPreviewView.playerView.player?.seek(to: CMTimeMakeWithSeconds(TIMES[index]!, 60),
                                                               toleranceBefore: CMTimeMake(1, 60),
                                                               toleranceAfter: CMTimeMake(1, 60))
        
        
        self.cameraScrubberPreviewConstraint.constant = 20 + CGFloat(distance)
    }
    
    func recordButtonDraggingHasEnded() {
        self.cameraScrubberPreviewView.isHidden = true
    }
    
}

extension ViewController: PlayerPlaybackDelegate {
    
    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    public func playerPlaybackDidEnd(_ player: Player) {
    }
    
    public func playerCurrentTimeDidChange(_ player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
        
        self.scrubberView.waveformView.progressSamples = Int(CGFloat(fraction) * CGFloat(self.scrubberView.waveformView.totalSamples))
    }
    
    public func playerPlaybackWillLoop(_ player: Player) {
        //        self. _playbackViewController?.reset()
    }
    
}
