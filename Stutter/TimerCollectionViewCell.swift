//
//  TimerCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/10/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import MZTimerLabel
import Cartography

class TimerCollectionViewCell : UICollectionViewCell {
    
    
    lazy var timerLabel:MZTimerLabel = {
        let timerLabel:MZTimerLabel = MZTimerLabel(timerType: MZTimerLabelTypeTimer)
        timerLabel.setCountDownTime(15)
        timerLabel.timeFormat = "s 'seconds'"
        timerLabel.timeLabel.textColor = UIColor.white
        timerLabel.timeLabel.font = UIFont.systemFont(ofSize: 15)
        timerLabel.timeLabel.textAlignment = .center
        timerLabel.adjustsFontSizeToFitWidth = true
        
        timerLabel.delegate = self
        
        return timerLabel
    }()
    
    lazy var timerView:UIView = {
        let containerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 20))
        containerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.clipsToBounds = true
        containerView.addSubview(blurEffectView)
        
        constrain(blurEffectView) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
        
        containerView.addSubview(self.timerLabel)
        
        constrain(self.timerLabel) { (view) in
            view.width == 130
            view.height == 20
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        self.timerLabel.timeLabel.setNeedsDisplay()
        
        return containerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.timerView)
        
        constrain(self.timerView) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        self.timerView.makeCircular()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension TimerCollectionViewCell : MZTimerLabelDelegate {
    
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
//        DispatchQueue.main.async {
//            self.exportButtonTapped()
//        }
    }
    
    func timerLabel(_ timerLabel: MZTimerLabel!, countingTo time: TimeInterval, timertype timerType: MZTimerLabelType) {
        //        self.imageView.image = self.generateBez(text: "\(Int(time))s")
    }
}
