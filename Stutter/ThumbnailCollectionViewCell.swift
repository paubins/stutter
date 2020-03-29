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
    lazy var thumbnailImageView:UIImageView = {
        let imageView:UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(thumbnailImageView)
        
        constrain(thumbnailImageView) { (view) in
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
