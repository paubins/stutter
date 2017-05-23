//
//  PlaybackBarView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/23/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

class PlaybackBarView: UIView {
    
    let padding = 0
    
    var tick:UIView!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.magenta
        
        self.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        self.tick = UIView(frame: CGRect.zero)
        self.tick.translatesAutoresizingMaskIntoConstraints = false
        self.tick.backgroundColor = UIColor.white
        
        self.addSubview(self.tick)
        
        self.tick.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.tick.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
