//
//  PlayButtonCollectionViewControllerCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import SwiftyButton

protocol PlayButtonCollectionViewControllerCellDelegate {
    func playButtonTapped(cell: PlayButtonCollectionViewControllerCell)
}

class PlayButtonCollectionViewControllerCell : UICollectionViewCell {
    
    var delegate:PlayButtonCollectionViewControllerCellDelegate!
    
    var color:UIColor!
    
    lazy var button0:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.addTarget(self, action: #selector(self.tapped), for: .touchUpInside)
        button.colors = .init(button: self.color,
                              shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
 
//        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureMethod)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.button0)
        
        constrain(self.button0) { (view) in
            view.top == view.superview!.top
            view.centerX == view.superview!.centerX
            view.bottom == view.superview!.bottom
            view.height == 50
            view.width == 50
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tapped(button: PressableButton) {
        self.delegate.playButtonTapped(cell: self)
    }
}
