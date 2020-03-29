//
//  ButtonViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import FontAwesomeKit
import SwiftyButton
import Emoji

protocol ButtonViewControllerDelegate {
    func assetChosen(asset: AVAsset)
}

class ButtonViewController : UIViewController {
    
    var delegate:ButtonViewControllerDelegate!
    
    lazy var picker:UIImagePickerController = {
        let picker:UIImagePickerController = UIImagePickerController()
        
        picker.videoQuality = .typeHigh
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.cameraDevice = .front
        picker.delegate = self
        
        return picker
    }()
    
    lazy var picker2:UIImagePickerController = {
        let picker2:UIImagePickerController = UIImagePickerController()
        
        picker2.allowsEditing = true
        picker2.sourceType = .photoLibrary
        picker2.mediaTypes = ["public.movie"]
        picker2.delegate = self
        
        return picker2
    }()
    
    
    let loadFromCameraButton:PressableButton = {
        let playStopBackButton:PressableButton = PressableButton()
        playStopBackButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        playStopBackButton.setTitle(":iphone:".emojiUnescapedString, for: .normal)
        playStopBackButton.addTarget(self, action: #selector(loadFromLibrary), for: .touchUpInside)
        playStopBackButton.cornerRadius = 40
        playStopBackButton.shadowHeight = 5
        return playStopBackButton
    }()
    
    let loadFromLibraryButton:PressableButton = {
        let playStopBackButton:PressableButton = PressableButton()
        playStopBackButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        playStopBackButton.setTitle(":video_camera:".emojiUnescapedString, for: .normal)
        playStopBackButton.addTarget(self, action: #selector(loadFromCamera), for: .touchUpInside)
        playStopBackButton.cornerRadius = 40
        playStopBackButton.shadowHeight = 5
        return playStopBackButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true

        self.view.addSubview(self.loadFromCameraButton)
        self.view.addSubview(self.loadFromLibraryButton)
        
        constrain(self.loadFromCameraButton, self.loadFromLibraryButton) { (view, view1) in
            view.right == view.superview!.right - 15
            view.top == view.superview!.top + 40
            view.height == 60
            view.width == 60
            
            view1.right == view1.superview!.right - 15
            view1.top == view.bottom + 15
            view1.height == 60
            view1.width == 60
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.loadFromLibraryButton.makeCircular()
        self.loadFromCameraButton.makeCircular()
    }
    
    @objc func loadFromCamera(sender: UIButton) {
        self.present(self.picker, animated: true) {
            print("load from library")
        }
    }
    
    @objc func loadFromLibrary(sender: UIButton) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.present(self.picker2, animated: true) {
                            print("load from camera")
                        }
                    }
                } else {}
            })
        } else if photos == .authorized {
            self.present(self.picker2, animated: true) {
                print("load from camera")
            }
        }
    }
}

extension ButtonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let url:URL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
        if (self.picker == picker) {
            self.picker.dismiss(animated: true, completion: {
                print("dismissed image picker")
            })
        } else {
            self.picker2.dismiss(animated: true, completion: {
                print("dismissed image picker")
            })
        }
        
        self.delegate.assetChosen(asset: AVAsset(url: url))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        
        picker.dismiss(animated: true) {
            print("dismissed")
        }
    }
}
