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
    
    func timelineScrubbingHasBegun(point: CGPoint)
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint)
    func timelineScrubbingHasEnded(point: CGPoint)
}

class ScrubberCollectionViewCell : UICollectionViewCell {
    
    var delegate:ScrubberCollectionViewCellDelegate!

    lazy var shapeView:ShapeView = {
        let shapeView:ShapeView = ShapeView(frame: .zero, count: 5)
        shapeView.delegate = self
        shapeView.backgroundColor = .clear
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
    
    func getTimelinePercentageX(index: Int) -> CGFloat {
        return self.shapeView.getTimelinePercentageX(index: index)
    }
    
    func getPercentageX(index: Int) -> CGFloat {
        return self.shapeView.getPercentageX(index: index)
    }
    
    func getSpeedPercentageX(index: Int) -> CGFloat {
        return self.shapeView.getSpeedPercentageX(index: index)
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
    
    func tapped() {
        self.delegate.tapped()
    }
    
    func timelineScrubbingHasBegun(point: CGPoint) {
        self.delegate.timelineScrubbingHasBegun(point: point)
    }
    
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint) {
        self.delegate.timelinePercentageOfWidth(index: index, percentageX: percentageX, percentageY: percentageY, point: point)
    }
    
    func timelineScrubbingHasEnded(point: CGPoint) {
        self.delegate.timelineScrubbingHasEnded(point: point)
    }
}
