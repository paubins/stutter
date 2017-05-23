//
//  ViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

let WIDTH_CONSTANT = CGFloat(70.0)

class ViewController: UIViewController {
    
    let progressView:ProgressView = ProgressView(frame: CGRect.zero)
    let scrubberView:ScrubberView = ScrubberView(frame: CGRect.zero)
    let cameraView:CameraView = CameraView(frame: CGRect.zero)
    let exportButton:ExportView = ExportView(frame: CGRect.zero)
    let playButtonsView:PlayButtonsView = PlayButtonsView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.scrubberView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.exportButton)
        self.view.addSubview(self.progressView)
        
        self.exportButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.exportButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.exportButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.exportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.progressView.bottomAnchor.constraint(equalTo: self.exportButton.topAnchor).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
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
        
        self.cameraView.bottomAnchor.constraint(equalTo: self.scrubberView.topAnchor).isActive = true
        self.cameraView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.cameraView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.exportButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        self.playButtonsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.view == self.exportButton {
            print("export files")
        } else if gestureRecognizer.view == self.scrubberView {
            print("scrubber view")
        } else if gestureRecognizer.view == self.playButtonsView {
            print("played a button")
        } else if gestureRecognizer.view == self.cameraView {
            print("pressed camera view")
        }
    }
}
