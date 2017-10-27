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

protocol ButtonViewControllerDelegate {
    func assetChosen(asset: AVAsset)
    func exportButtonTapped()
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
        
        containerView.alpha = 0.0
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        self.view.addSubview(self.loadFromCameraButton)
        self.view.addSubview(self.loadFromLibraryButton)
        self.view.addSubview(self.saveShareButton)
        
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.loadFromLibraryButton.makeCircular()
        self.loadFromCameraButton.makeCircular()
        self.saveShareButton.makeCircular()
    }
    
    func loadFromCamera(sender: UIButton) {
        self.present(self.picker, animated: true) {
            print("load from library")
        }
    }
    
    func loadFromLibrary(sender: UIButton) {
        self.present(self.picker2, animated: true) {
            print("load from camera")
        }
    }
    
    func saveVideo(sender: UIButton) {
        self.delegate.exportButtonTapped()
    }
    
    func turnOnShareButton() {
        if (self.saveShareButton.alpha == 0.0) {
            UIView.animate(withDuration: 0.5) {
                self.saveShareButton.alpha = 1.0
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
}

extension ButtonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked media")
        
        let url:URL = info[UIImagePickerControllerMediaURL] as! URL
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
