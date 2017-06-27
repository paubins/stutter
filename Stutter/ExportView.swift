//
//  ExportView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import SwiftyButton

let NEW_WIDTH_CONSTANT = CGFloat(10)

protocol ExportViewDelegate {
    func stopButtonWasTapped()
    func exportButtonWasTapped()
    func resetButtonWasTapped()
    func playButtonWasTapped()
}

class ExportView : UIView {
    var delegate: ExportViewDelegate?
    
    var activityLoader:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        let containerView:UIView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        
        containerView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        let playButton:PressableButton = PressableButton()
        playButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                  shadow: UIColor.black)
        playButton.shadowHeight = 3
        playButton.cornerRadius = 5
        playButton.setTitle("Play", for: .normal)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        activityLoader.isHidden = true
     
        containerView.addSubview(playButton)
        
        let stopButton:PressableButton = PressableButton()
        stopButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                  shadow: UIColor.black)
        stopButton.shadowHeight = 3
        stopButton.cornerRadius = 5
        stopButton.setTitle("Stop", for: .normal)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stopButton)
        containerView.addSubview(activityLoader)
        
        let spacer:UIView = UIView(frame: .zero)
        containerView.addSubview(spacer)
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        playButton.leftAnchor.constraint(equalTo: spacer.rightAnchor).isActive = true
        playButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let spacer9:UIView = UIView(frame: .zero)
        containerView.addSubview(spacer9)
        
        spacer9.translatesAutoresizingMaskIntoConstraints = false
        spacer9.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer9.leftAnchor.constraint(equalTo: playButton.rightAnchor).isActive = true
        
        stopButton.leftAnchor.constraint(equalTo: spacer9.rightAnchor).isActive = true
        stopButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        stopButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let resetButton:PressableButton = PressableButton()
        containerView.addSubview(resetButton)
        
        resetButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                   shadow: UIColor.black)
        resetButton.shadowHeight = 3
        resetButton.cornerRadius = 5
        resetButton.setTitle("Reset", for: .normal)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        let spacer0:UIView = UIView(frame: .zero)
        containerView.addSubview(spacer0)
        
        spacer0.translatesAutoresizingMaskIntoConstraints = false
        spacer0.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer0.leftAnchor.constraint(equalTo: stopButton.rightAnchor).isActive = true
        
        resetButton.leftAnchor.constraint(equalTo: spacer0.rightAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        resetButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let spacer1:UIView = UIView(frame: .zero)
        containerView.addSubview(spacer1)
        
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        spacer1.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer1.leftAnchor.constraint(equalTo: resetButton.rightAnchor).isActive = true

        let exportButton:PressableButton = PressableButton()
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                    shadow: UIColor.black)
        exportButton.shadowHeight = 3
        exportButton.cornerRadius = 5
        exportButton.setTitle("Save", for: .normal)

        containerView.addSubview(exportButton)

        
        let spacer2:UIView = UIView(frame: .zero)
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spacer2)
        
        exportButton.leftAnchor.constraint(equalTo: spacer1.rightAnchor).isActive = true
        exportButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        exportButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        spacer2.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer2.leftAnchor.constraint(equalTo: exportButton.rightAnchor).isActive = true
        
        let spacer3:UIView = UIView(frame: .zero)
        spacer3.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spacer3)
        
        spacer3.widthAnchor.constraint(equalToConstant: 10).isActive = true
        spacer3.leftAnchor.constraint(equalTo: exportButton.rightAnchor).isActive = true
        spacer3.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        activityLoader.centerXAnchor.constraint(equalTo: exportButton.centerXAnchor).isActive = true
        activityLoader.centerYAnchor.constraint(equalTo: exportButton.centerYAnchor).isActive = true
        
        playButton.widthAnchor.constraint(equalTo: resetButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        stopButton.widthAnchor.constraint(equalTo: playButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        resetButton.widthAnchor.constraint(equalTo: exportButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        
        playButton.addTarget(self, action: #selector(self.playButtonWasTapped), for: [.touchUpInside])
        stopButton.addTarget(self, action: #selector(self.stopButtonWasTapped), for: [.touchUpInside])
        
        resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.resetButtonWasTapped)))
        exportButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.exportButtonWasTapped)))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetExportButton() {
        self.activityLoader.isHidden = true
        self.activityLoader.stopAnimating()
    }
}

extension ExportView {
    func stopButtonWasTapped(sender: PressableButton) {
        self.delegate?.stopButtonWasTapped()
    }
    
    func playButtonWasTapped(sender: PressableButton) {
        self.delegate?.playButtonWasTapped()
    }
    
    func resetButtonWasTapped() {
        self.delegate?.resetButtonWasTapped()
    }
    
    func exportButtonWasTapped() {
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        
        self.delegate?.exportButtonWasTapped()
    }
}
