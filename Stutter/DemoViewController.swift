//
//  DemoViewController.swift
//  Translucid
//
//  Created by Lucas Ortis on 18/12/2015.
//  Copyright © 2015 Ekhoo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DemoViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.white
        
        let deviceScreenSize: CGFloat = UIScreen.main.bounds.height
        let offset: CGFloat = deviceScreenSize > 320.0 ? 50.0 : 35.0
        
        let star: Translucid = Translucid(frame: CGRect(x: 0.0, y: offset, width: self.view.frame.width, height: self.view.frame.height / 2.0))
        star.font = UIFont(name: "Starjedi", size: 20)!
        star.text = "Star"
        star.backgroundImage = UIImage(named: "stars")
        
        let newLayer:CALayer = CALayer()
        newLayer.backgroundColor = UIColor.black.cgColor
        
        star.backgroundLayer.addSublayer(newLayer)

        let wars: Translucid = Translucid(frame: CGRect(x: 0.0, y: self.view.frame.height / 2.0 - offset, width: self.view.frame.width, height: self.view.frame.height / 2.0))
        wars.font = UIFont(name: "Starjedi", size: 20)!
        wars.text = "Wars"
        wars.backgroundImage = UIImage(named: "stars")
        
        self.view.addSubview(star)
        self.view.addSubview(wars)
        
        
//        star.animate()
        wars.animate()
    }
    
}
