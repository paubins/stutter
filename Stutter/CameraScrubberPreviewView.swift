//
//  CameraScrubberPreviewView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/24/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import AVFoundation

class CameraScrubberPreviewView : UIView {
 
    var playerView:PlayerView = PlayerView(frame: CGRect.zero)

    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.playerView)
        
        self.playerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.playerView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.playerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
