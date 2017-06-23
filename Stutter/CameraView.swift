//
//  CameraView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import SwiftyButton
import DynamicButton
import GlitchLabel

let DEFAULT_PROGRESS = CGFloat(30)

protocol CameraViewDelegate {
    func recordingHasStoppedWithLength(time: Int)
    func recordingHasBegun()
    func recordButtonPressed()
    func cameraFlipButtonPressed()
}

class CameraView : UIView {
    
    var recordButton:UIView!
    var recordProgressLayoutConstraint:NSLayoutConstraint!
    var timer:Timer!
    
    var currentTime:Float = 0.0
    
    var delegate: CameraViewDelegate?
    
    let recordButtonProgressView:PressableButton = {
        let view = PressableButton(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        view.colors = .init(button: UIColor(rgbColorCodeRed: 135, green: 135, blue: 135, alpha: 1.0),
                              shadow: .blue)
        view.shadowHeight = 5
        view.cornerRadius = 28
        
        return view
    }()
    
    let flipButton:UIView = {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view:DynamicButton = DynamicButton(style: .reload)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        container.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: 20).isActive = true
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.strokeColor = .black
        view.highlightStokeColor = .gray
        
        return container
    }()
    
    let importButton:UIView = {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view = DynamicButton(style: .stop)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: 35).isActive = true
        view.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        return container
    }()
    
    let backButton:UIView = {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view:UIView = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.backgroundColor = UIColor.blue
        return container
    }()
    
    let backButtonLabel:UILabel = {
        let label:UILabel = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Back"
        return label
    }()
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear

        container.addSubview(view)
        
        view.addSubview(self.recordButtonProgressView)
        
        self.recordButtonProgressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.recordButtonProgressView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.recordButtonProgressView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.recordProgressLayoutConstraint = self.recordButtonProgressView.widthAnchor.constraint(equalTo: view.widthAnchor)
        self.recordProgressLayoutConstraint.isActive = true
        
        self.recordButton = container
        
        container.layer.cornerRadius = 50;
        container.layer.masksToBounds = true;
        container.clipsToBounds = true
        
        self.recordButtonProgressView.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
//        self.recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.flipButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.importButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))

        self.addSubview(self.flipButton)
        self.addSubview(self.importButton)
        self.addSubview(self.recordButton)
        
//        let glitchLabel:GlitchLabel = GlitchLabel()
//        glitchLabel.translatesAutoresizingMaskIntoConstraints = false
//        glitchLabel.text = "Stutter"
//        glitchLabel.font = UIFont.boldSystemFont(ofSize: 80)
//        glitchLabel.blendMode = .multiply
//        glitchLabel.sizeToFit()
//        self.addSubview(glitchLabel)
//        
//        glitchLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        glitchLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        self.recordButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.recordButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.recordButton.heightAnchor.constraint(equalToConstant: 120).isActive = true
        self.recordButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.flipButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.flipButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        self.flipButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.flipButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.importButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.importButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.importButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.importButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraView {
    func recordButtonPressed(sender: PressableButton) {
        self.delegate?.recordButtonPressed()
    }
    
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.view == self.backButton) {
            print("go back")
        } else if (gestureRecognizer.view == self.flipButton)  {
            print("camera should flip")
        } else if (gestureRecognizer.view == self.importButton) {
            print("import videos")
        } else {
            
            
//            if (self.timer != nil) {
//                self.delegate?.recordingHasStoppedWithLength(time: Int(100 * self.currentTime))
//                self.currentTime = 0
//                self.timer.invalidate()
//                self.timer = nil
//            } else {
//                self.delegate?.recordingHasBegun()
//                self.recordProgressLayoutConstraint.constant = DEFAULT_PROGRESS
//                self.recordProgressLayoutConstraint.constant = 1
//                self.timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
//            }
        }
    }
    
    func updateProgress(timer: Timer) {
        print("timer fired")
        if (self.recordButtonProgressView.frame.width < 60) {
            self.currentTime += 0.35
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.recordProgressLayoutConstraint.constant += 1
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
        } else {
            print("timer over")
            self.timer.invalidate()
        }
    }
    
    func flipCamera(sender: UIButton) {
        self.delegate?.cameraFlipButtonPressed()
    }
}
