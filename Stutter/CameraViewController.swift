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

class CameraViewController : SwiftyCamViewController {
    
    var imagePickerViewController:UIImagePickerController!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //        let recordButton:PressableButton = PressableButton()
        //        recordButton.translatesAutoresizingMaskIntoConstraints = false
        //        recordButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
        //                                    shadow: UIColor.black)
        //        recordButton.shadowHeight = 3
        //        recordButton.cornerRadius = 5
        //        recordButton.setTitle("Record", for: .normal)
        
        let button1 : SDevCircleButton = SDevCircleButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
//        button1.addTarget(self, action: #selector(self.recordButtonWasTapped), for: [.touchUpInside])
        
        let longPressGestureRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordButtonWasTapped))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        
        button1.addGestureRecognizer(longPressGestureRecognizer)
        
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
    }
    
    func flipCamera() {
        self.switchCamera()
    }
    
//    func recordButtonWasTapped(button: SDevCircleButton) {
//
//
//        if(button.state == .normal) {
//            self.startVideoRecording()
//        } else if (button.state == .selected) {
//            self.stopVideoRecording()
//        }
//    }
    
    var buttonTimer:Timer!
    
    func recordButtonWasTapped(sender: UILongPressGestureRecognizer) {
        let button:SDevCircleButton = sender.view as! SDevCircleButton
        
        if(sender.state == UIGestureRecognizerState.began) {
            self.startVideoRecording()
            
            self.buttonTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            
        } else if (sender.state == UIGestureRecognizerState.ended) {
            self.buttonTimer.invalidate()
            self.dismiss(animated: true, completion: {
                self.stopVideoRecording()
            })
        }
    }
    
    func presentImagePickerViewController() {
        self.imagePickerViewController = UIImagePickerController()
        self.imagePickerViewController.delegate = self
        self.imagePickerViewController.sourceType = .savedPhotosAlbum
        self.imagePickerViewController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        
        self.present(self.imagePickerViewController, animated: false) {
            
        }
    }
    
    func timerFired(timer: Timer) {
        self.recordButton.animateTap = true
        self.recordButton.triggerAnimateTap()
    }
}

extension CameraViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
//        self.asset = AVAsset(url: videoURL as URL)
//        
//        self.imagePickerViewController.dismiss(animated: true) {
//            self.view.setNeedsLayout()
//        }
//        
//        self.processAsset()
    }
}



