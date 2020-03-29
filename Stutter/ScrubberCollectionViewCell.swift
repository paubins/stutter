//
//  ScrubberCollectionViewCell.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography

protocol ScrubberCollectionViewCellDelegate {
    func scrubbingHasBegun(at: CGPoint)
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat, to: CGPoint)
    func scrubbingHasEnded(at: CGPoint)
    func tapped()
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
    
    func getPoint(for index:Int) -> CGPoint {
        return self.shapeView.getPoint(for: index)
    }
    
    func getPercentageX(index: Int) -> CGFloat {
        return self.shapeView.getPercentageX(index: index)
    }
    
    func getPercentageY(index: Int) -> CGFloat {
        return self.shapeView.getPercentageY(index: index)
    }
}

extension ScrubberCollectionViewCell : ShapeViewDelegate {
    func slidingHasBegun(point: CGPoint) {
        self.delegate.scrubbingHasBegun(at: point)
    }
    
    func percentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint) {
        self.delegate.scrubbed(index: index, percentageX: percentageX, percentageY: percentageY, to: point)
    }
    
    func slidingHasEnded(point: CGPoint) {
        self.delegate.scrubbingHasEnded(at: point)
    }
}
