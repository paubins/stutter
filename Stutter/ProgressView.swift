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
    var final = false
    
    var currentProgressLayoutConstraint:NSLayoutConstraint!
    var progressBars:[UIView] = []
    
    let colors = [UIColor.black, UIColor.gray, UIColor.blue, UIColor.darkGray, UIColor.brown]
    
    var timer:Timer!
    
    var currentIndex:Int!
    var currentProgress:UIView!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startProgress(index: Int) {
        self.currentProgress = UIView(frame: CGRect.zero)
        currentProgress.translatesAutoresizingMaskIntoConstraints = false

        currentProgress.backgroundColor = self.colors[index]
        
        self.addSubview(currentProgress)
        
        currentProgress.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        currentProgress.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        if (self.progressBars.count > 0) {
            currentProgress.leftAnchor.constraint(equalTo: (self.progressBars.last?.rightAnchor)!).isActive = true
        } else {
            currentProgress.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        }
        
        self.currentProgressLayoutConstraint = currentProgress.widthAnchor.constraint(equalToConstant: 0)
        self.currentProgressLayoutConstraint.isActive = true
        
        self.progressBars.append(currentProgress)
    }
    
    func updateProgress(index: Int) {
        if(self.final) {
            print("that's final")
            return
        }
        
        if(self.timer != nil) {
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.currentIndex = index
        self.startProgress(index: index)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                          selector: #selector(extendCurrentProgressView),
                                          userInfo: nil, repeats: true)
    }
}

extension ProgressView  {
    func extendCurrentProgressView() {
        self.currentProgressLayoutConstraint.constant += 1
        let width = self.currentProgress.frame.origin.x + self.currentProgress.frame.size.width
        if (UIScreen.main.bounds.size.width < width) {
            self.timer.invalidate()
            self.timer = nil
            self.final = true
        }
    }
}
