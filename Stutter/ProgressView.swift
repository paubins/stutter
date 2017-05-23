//
//  ProgressView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    let padding = 0
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.green
        
        let progressSoFarView:UIView = {
            let view = UIView(frame: CGRect.zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.purple
            return view
        }()
        
        self.addSubview(progressSoFarView)
        
        progressSoFarView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        progressSoFarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        progressSoFarView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressSoFarView.widthAnchor.constraint(equalToConstant: 123).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
