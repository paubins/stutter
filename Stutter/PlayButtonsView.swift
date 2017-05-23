//
//  PlayButtonsView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

class PlayButtonsView: UIView {
    
    let padding = 0
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.red
        
        let button0 = UIView(frame: CGRect.zero)
        button0.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button0)
        
        button0.backgroundColor = UIColor.black
        button0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button0.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        button0.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        let button1 = UIView(frame: CGRect.zero)
        button1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button1)
        
        button1.backgroundColor = UIColor.gray
        button1.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button1.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button1.leftAnchor.constraint(equalTo: button0.rightAnchor).isActive = true
        button1.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        button1.backgroundColor = UIColor.gray
        
        let button2 = UIView(frame: CGRect.zero)
        button2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button2)
        
        button2.backgroundColor = UIColor.blue
        button2.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button2.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button2.leftAnchor.constraint(equalTo: button1.rightAnchor).isActive = true
        button2.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        let button3 = UIView(frame: CGRect.zero)
        button3.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button3)
        
        button3.backgroundColor = UIColor.darkGray
        button3.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button3.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button3.leftAnchor.constraint(equalTo: button2.rightAnchor).isActive = true
        button3.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        let button4 = UIView(frame: CGRect.zero)
        button4.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button4)
        
        button4.backgroundColor = UIColor.brown
        button4.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button4.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button4.leftAnchor.constraint(equalTo: button3.rightAnchor).isActive = true
        button4.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        button4.widthAnchor.constraint(greaterThanOrEqualToConstant: WIDTH_CONSTANT).isActive = true
        
        button1.widthAnchor.constraint(equalTo: button2.widthAnchor, multiplier: 1, constant: 0).isActive = true
        button2.widthAnchor.constraint(equalTo: button3.widthAnchor, multiplier: 1, constant: 0).isActive = true
        button3.widthAnchor.constraint(equalTo: button4.widthAnchor, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
