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
    
    let tickContainer:UIView = UIView(frame: CGRect.zero)
    let tick:UIView = UIView(frame: CGRect.zero)
    
    let colors = [UIColor.black, UIColor.gray, UIColor.blue, UIColor.darkGray, UIColor.brown]
    
    var timer:Timer!
    var playbackTimer:Timer!
    
    var currentIndex:Int!
    var currentProgress:UIView!
    
    var tickContainerWidthAnchor:NSLayoutConstraint!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.green
        
        self.tickContainer.translatesAutoresizingMaskIntoConstraints = false
        self.tickContainer.addSubview(self.tick)
        self.addSubview(self.tickContainer)
        
        self.tick.backgroundColor = UIColor.magenta
        self.tick.translatesAutoresizingMaskIntoConstraints = false
        self.tick.widthAnchor.constraint(equalToConstant: 2).isActive = true
        self.tick.topAnchor.constraint(equalTo: self.tickContainer.topAnchor).isActive = true
        self.tick.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.tick.rightAnchor.constraint(equalTo: self.tickContainer.rightAnchor).isActive = true
        
        self.tickContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.tickContainer.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.tickContainerWidthAnchor = self.tickContainer.widthAnchor.constraint(equalToConstant: 2)
        self.tickContainerWidthAnchor.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startProgress(index: Int) {
        self.currentProgress = UIView(frame: CGRect.zero)
        currentProgress.translatesAutoresizingMaskIntoConstraints = false

        currentProgress.backgroundColor = self.colors[index]
        
        self.addSubview(currentProgress)
        
        currentProgress.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        if (self.progressBars.count > 0) {
            currentProgress.leftAnchor.constraint(equalTo: (self.progressBars.last?.rightAnchor)!).isActive = true
        } else {
            currentProgress.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        }
        
        currentProgress.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
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
    
    func resetProgress() {
        if (self.timer != nil) {
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.progressBars = []
        self.final = false
        self.currentIndex = 0
        self.currentProgressLayoutConstraint = nil
        
        for subview in self.subviews {
            if(subview != self.tickContainer) {
                subview.removeFromSuperview()
            }
        }
    }
    
    func playback() {
        if(self.timer == nil) {
            self.playbackTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                                      selector: #selector(showPlayback),
                                                      userInfo: nil, repeats: true)
        }
    }
}

extension ProgressView  {
    func showPlayback() {
        self.tickContainerWidthAnchor.constant += 1
        let width = self.tickContainer.frame.origin.x + self.tickContainer.frame.size.width
        if (UIScreen.main.bounds.size.width < width) {
            self.playbackTimer.invalidate()
            self.playbackTimer = nil
            self.tickContainerWidthAnchor.constant = 2
        }
    }
    
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
