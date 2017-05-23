//
//  ExportView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

let NEW_WIDTH_CONSTANT = CGFloat(120)

protocol ExportViewDelegate {
    func exportButtonWasTapped()
    func resetButtonWasTapped()
    func playButtonWasTapped()
}

class ExportView : UIView {
    var delegate: ExportViewDelegate?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.cyan
        
        let playButton = UIView(frame: CGRect.zero)
        playButton.backgroundColor = UIColor.orange
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        var label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Play"

        playButton.addSubview(label)
        self.addSubview(playButton)
        
        label.centerXAnchor.constraint(equalTo: playButton.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        
        playButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        playButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        playButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        playButton.widthAnchor.constraint(greaterThanOrEqualToConstant: NEW_WIDTH_CONSTANT).isActive = true
        
        let resetButton = UIView(frame: CGRect.zero)
        resetButton.backgroundColor = UIColor.darkGray
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Reset"
        
        resetButton.addSubview(label)
        self.addSubview(resetButton)
        
        label.centerXAnchor.constraint(equalTo: resetButton.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor).isActive = true
        
        resetButton.leftAnchor.constraint(equalTo: playButton.rightAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        resetButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        resetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        let exportButton = UIView(frame: CGRect.zero)
        exportButton.translatesAutoresizingMaskIntoConstraints = false

        label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Export"
        
        exportButton.addSubview(label)
        self.addSubview(exportButton)
        
        exportButton.leftAnchor.constraint(equalTo: resetButton.rightAnchor).isActive = true
        exportButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        exportButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        exportButton.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        label.centerXAnchor.constraint(equalTo: exportButton.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: exportButton.centerYAnchor).isActive = true
        
        playButton.widthAnchor.constraint(equalTo: resetButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        resetButton.widthAnchor.constraint(equalTo: exportButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        exportButton.widthAnchor.constraint(equalTo: playButton.widthAnchor, multiplier: 1, constant: 0).isActive = true
        
        playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.playButtonWasTapped)))
        resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.resetButtonWasTapped)))
        exportButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.exportButtonWasTapped)))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ExportView {
    
    func playButtonWasTapped() {
        self.delegate?.playButtonWasTapped()
    }
    
    func resetButtonWasTapped() {
        self.delegate?.resetButtonWasTapped()
    }
    
    func exportButtonWasTapped() {
        self.delegate?.exportButtonWasTapped()
    }
}
