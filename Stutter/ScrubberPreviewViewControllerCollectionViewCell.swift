//
//  RecordButtonCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography

class ScrubberPreviewViewControllerCollectionViewCell : UICollectionViewCell {
    
    var duration:CMTime = kCMTimeZero
    
    lazy var scrubberPreviewViewController:ScrubberPreviewViewController = {
        let scrubberPreviewViewController:ScrubberPreviewViewController = ScrubberPreviewViewController()
        return scrubberPreviewViewController
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.scrubberPreviewViewController.view)
        
        constrain(self.scrubberPreviewViewController.view) { (view1) in
            view1.top == view1.superview!.top
            view1.left == view1.superview!.left
            view1.right == view1.superview!.right
            view1.bottom == view1.superview!.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(asset: AVAsset) {
        self.scrubberPreviewViewController.load(asset: asset)
    }
    
    func showScrubberPreview() {
        scrubberPreviewViewController.show()
    }
    
    func seek(to: CGFloat) {
        self.scrubberPreviewViewController.seek(to: CMTimeMakeWithSeconds(Float64(CGFloat(CMTimeGetSeconds(self.duration)) * to), 60))
    }
    
    func hideScrubberPreview() {
        self.scrubberPreviewViewController.hide()
    }
}
