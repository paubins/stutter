//
//  ZoomLevelView.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/6/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class ZoomLevelView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let layer:ZoomLayer = ZoomLayer()
        
        layer.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - (Constant.controlSurfaceHeight + Constant.mainControlHeight),
                             width: UIScreen.main.bounds.width, height: Constant.mainControlHeight)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        
        self.layer.addSublayer(layer)
        layer.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
        
//        self.layer.frame = self.bounds
        self.layer.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
