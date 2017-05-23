//
//  FlipperView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

class FlipperView: UIView {

    let padding = 0
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.frame = CGRect(x: frame.origin.x + padding, y: frame.origin.y, width: frame.width, height: frame.height)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
