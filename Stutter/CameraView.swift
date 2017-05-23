//
//  CameraView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

let DEFAULT_PROGRESS = CGFloat(30)

class CameraView : UIView {
    
    var recordButton:UIView!
    var recordProgressLayoutConstraint:NSLayoutConstraint!
    var timer:Timer!
    
    let recordButtonProgressView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        
        return view
    }()
    
    let flipButton:UIView = {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.magenta
        
        container.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return container
    }()
    
    let importButton:UIView = {
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.magenta
        
        container.addSubview(view)
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        view.widthAnchor.constraint(equalToConstant: 25).isActive = true
        view.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
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
        self.backgroundColor = UIColor.black
        
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        
        container.addSubview(view)
        
        view.addSubview(self.recordButtonProgressView)
        
        self.recordButtonProgressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.recordButtonProgressView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.recordButtonProgressView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.recordProgressLayoutConstraint = recordButtonProgressView.widthAnchor.constraint(equalToConstant: DEFAULT_PROGRESS)
        self.recordProgressLayoutConstraint.isActive = true
        
        self.recordButton = container
        
        self.recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.flipButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.importButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        
        self.backButton.addSubview(self.backButtonLabel)
        
        self.addSubview(self.backButton)
        self.addSubview(self.flipButton)
        self.addSubview(self.importButton)
        self.addSubview(self.recordButton)
        
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
        
        self.importButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.importButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.backButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.backButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backButton.heightAnchor.constraint(equalToConstant: 120).isActive = true
        self.backButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.backButtonLabel.centerXAnchor.constraint(equalTo: self.backButton.centerXAnchor).isActive = true
        self.backButtonLabel.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraView {
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if (gestureRecognizer.view == self.backButton) {
            print("go back")
        } else if (gestureRecognizer.view == self.flipButton)  {
            print("camera should flip")
        } else if (gestureRecognizer.view == self.importButton) {
            print("import videos")
        } else {
            if (self.timer != nil) {
                self.timer.invalidate()
                self.timer = nil
            } else {
                self.recordProgressLayoutConstraint.constant = DEFAULT_PROGRESS
                self.recordProgressLayoutConstraint.constant = 1
                self.timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            }
        }
    }
    
    func updateProgress(timer: Timer) {
        print("timer fired")
        if (self.recordButtonProgressView.frame.width < 60) {
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
}
