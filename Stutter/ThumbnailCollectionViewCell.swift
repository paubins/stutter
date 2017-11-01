//
//  ThumbnailCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography

class ThumbnailCollectionViewCell : UICollectionViewCell {
    let thumbnailImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(thumbnailImageView)
        
        constrain(thumbnailImageView) { (view) in
            view.width == self.frame.size.width
            view.height == view.superview!.height
            view.left == view.superview!.left
            view.top == view.superview!.top
            view.height == 50
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
