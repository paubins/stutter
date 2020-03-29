//
//  ZoomLevelView.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/6/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class ZoomLevelView : UIView {
    
    var offset:CGFloat {
        get {
            return -20
        }
    }
    
    lazy var zoomLayer:ZoomLayer = {
        let layer:ZoomLayer = ZoomLayer()
        layer.frame = CGRect(x: 0, y: self.offset, width: UIScreen.main.bounds.width, height: Constant.mainControlHeight)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        
        return layer
    }()
    
    lazy var textLayer:CATextLayer = {
        let textLayer:CATextLayer = CATextLayer()
        textLayer.frame = CGRect(x: 15, y: self.offset + 15, width: 25, height: 25)
        textLayer.font = UIFont(name: "Helvetica", size: 13)?.fontName as CFTypeRef
        textLayer.fontSize = 15
        textLayer.string = "3x"
        textLayer.shouldRasterize = true
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        return textLayer
    }()
    
    lazy var textLayer2:CATextLayer = {
        let textLayer:CATextLayer = CATextLayer()
        textLayer.frame = CGRect(x: 15, y: self.offset + 115, width: 25, height: 25)
        textLayer.font = UIFont(name: "Helvetica", size: 20)?.fontName as CFTypeRef
        textLayer.fontSize = 15
        textLayer.string = "2x"
        textLayer.shouldRasterize = true
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        return textLayer
    }()
    
    lazy var textLayer3:CATextLayer = {
        let textLayer:CATextLayer = CATextLayer()
        textLayer.frame = CGRect(x: 15, y: self.offset + 215, width: 25, height: 25)
        textLayer.font = UIFont(name: "Helvetica", size: 20)?.fontName as CFTypeRef
        textLayer.fontSize = 15
        textLayer.string = "1x"
        textLayer.shouldRasterize = true
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        return textLayer
    }()
    
    lazy var textLayer4:CATextLayer = {
        let textLayer:CATextLayer = CATextLayer()
        textLayer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 20, y: self.offset + 214, width: 25, height: 25)
        textLayer.font = UIFont(name: "Helvetica", size: 20)?.fontName as CFTypeRef
        textLayer.fontSize = 15
        textLayer.string = "-"
        textLayer.shouldRasterize = true
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        return textLayer
    }()
    
    lazy var textLayer5:CATextLayer = {
        let textLayer:CATextLayer = CATextLayer()
        textLayer.frame = CGRect(x: UIScreen.main.bounds.width/2 + 12, y: self.offset + 214, width: 25, height: 25)
        textLayer.font = UIFont(name: "Helvetica", size: 20)?.fontName as CFTypeRef
        textLayer.fontSize = 15
        textLayer.string = "+"
        textLayer.shouldRasterize = true
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.rasterizationScale = UIScreen.main.scale
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        return textLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.layer.addSublayer(self.zoomLayer)
        self.layer.addSublayer(self.textLayer)
        self.layer.addSublayer(self.textLayer2)
        self.layer.addSublayer(self.textLayer3)
//        self.layer.addSublayer(self.textLayer4)
//        self.layer.addSublayer(self.textLayer5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.zoomLayer.setNeedsDisplay()
        self.textLayer.setNeedsDisplay()
        self.textLayer2.setNeedsDisplay()
        self.textLayer3.setNeedsDisplay()
//        self.textLayer4.setNeedsDisplay()
//        self.textLayer5.setNeedsDisplay()
        
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
