//
//  BezierController.m
//  Stutter
//
//  Created by Patrick Aubin on 6/27/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

#import "BezierController.h"

@implementation BezierController

+ (CAShapeLayer *)addBezierPathForPoints:(NSArray *)points toView:(UIView *)view
{
    UIBezierPath *_curve = [UIBezierPath bezierPath];
    _curve.contractionFactor = 0.6;
    [_curve moveToPoint:[points.firstObject CGPointValue]];
    [_curve addBezierThroughPoints:points];
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    _shapeLayer.fillColor = nil;
    _shapeLayer.lineWidth = 3;
    _shapeLayer.path = _curve.CGPath;
    
    [view.layer addSublayer:_shapeLayer];
    
    return _shapeLayer;
}

@end
