//
//  ScrubberCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import AHKBendableView

protocol ScrubberCollectionViewCellDelegate {
    func scrubbingHasBegun()
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat)
    func scrubbingHasEnded()
}

class ScrubberCollectionViewCell : UICollectionViewCell {
    
    var delegate:ScrubberCollectionViewCellDelegate!
    
    lazy var shapeView:ShapeView = {
        let shapeView:ShapeView = ShapeView(frame: .zero, count: 5)
        shapeView.delegate = self
        return shapeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        
        self.addSubview(self.shapeView)
        
        constrain(self.shapeView) { (view1) in
            view1.top == view1.superview!.top
            view1.left == view1.superview!.left
            view1.right == view1.superview!.right
            view1.bottom == view1.superview!.bottom
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shapeView.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPercentageX(index: Int) -> CGFloat {
        return self.shapeView.getPercentageX(index: index)
    }
    
    func getPercentageY(index: Int) -> CGFloat {
        return self.shapeView.getPercentageY(index: index)
    }
    
    func animate() {
        self.shapeView.animate()
    }
}

extension ScrubberCollectionViewCell : ShapeViewDelegate {
    func slidingHasBegun() {
        self.delegate.scrubbingHasBegun()
    }
    
    func percentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat) {
        self.delegate.scrubbed(index: index, percentageX: percentageX, percentageY: percentageY)
    }
    
    func slidingHasEnded() {
        self.delegate.scrubbingHasEnded()
    }
}
