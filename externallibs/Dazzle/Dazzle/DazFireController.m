//
//  DazFireController.m
//  Dazzle
//
//  Created by Leonhard Lichtschlag on 9/Feb/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "DazFireController.h"
#import <QuartzCore/CoreAnimation.h>

// ===============================================================================================================
@implementation DazFireController
// ===============================================================================================================

@synthesize fireEmitter;
@synthesize smokeEmitter;


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	CGRect viewBounds = self.view.layer.bounds;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
	// Create the emitter layers
	self.fireEmitter	= [CAEmitterLayer layer];
	self.smokeEmitter	= [CAEmitterLayer layer];
	
	// Place layers just above the tab bar
	self.fireEmitter.emitterSize	= CGSizeMake(viewBounds.size.width/2.0, 0);
	self.fireEmitter.emitterMode	= kCAEmitterLayerOutline;
	self.fireEmitter.emitterShape	= kCAEmitterLayerLine;
	// with additive rendering the dense cell distribution will create "hot" areas
	self.fireEmitter.renderMode		= kCAEmitterLayerAdditive;
    
	self.smokeEmitter.emitterMode	= kCAEmitterLayerPoints;
	
	// Create the fire emitter cell
	CAEmitterCell* fire = [CAEmitterCell emitterCell];
	[fire setName:@"fire"];

	fire.birthRate			= 1;
	fire.emissionLongitude  = M_PI;
	fire.velocity			= -80;
	fire.velocityRange		= 30;
	fire.emissionRange		= 1.1;
	fire.yAcceleration		= -200;
	fire.scaleSpeed			= 0.3;
	fire.lifetime			= 3;
	fire.lifetimeRange		= (3.0 * 0.35);

	fire.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
	fire.contents = (id) [[UIImage imageNamed:@"DazFire"] CGImage];
	
	
	// Create the smoke emitter cell
	CAEmitterCell* smoke = [CAEmitterCell emitterCell];
	[smoke setName:@"smoke"];

	smoke.birthRate			= 1;
	smoke.emissionLongitude = -M_PI / 2;
	smoke.lifetime			= 2;
	smoke.velocity			= -40;
	smoke.velocityRange		= 20;
	smoke.emissionRange		= M_PI / 4;
	smoke.spin				= 1;
	smoke.spinRange			= 6;
	smoke.yAcceleration		= -160;
	smoke.contents			= (id) [[UIImage imageNamed:@"DazSmoke"] CGImage];
	smoke.scale				= 0.1;
	smoke.alphaSpeed		= -0.12;
	smoke.scaleSpeed		= 0.7;
	
	
	// Add the smoke emitter cell to the smoke emitter layer
	self.smokeEmitter.emitterCells	= [NSArray arrayWithObject:smoke];
	self.fireEmitter.emitterCells	= [NSArray arrayWithObject:fire];
	[self.view.layer addSublayer:self.smokeEmitter];
	[self.view.layer addSublayer:self.fireEmitter];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[self.fireEmitter removeFromSuperlayer];
	self.fireEmitter = nil;
	[self.smokeEmitter removeFromSuperlayer];
	self.smokeEmitter = nil;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Interaction
// ---------------------------------------------------------------------------------------------------------------

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self controlFireHeight:event];
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self controlFireHeight:event];
}


- (void)controlFireLocation:(CGPoint)position withBadge:(NSInteger)badge {
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    
    if (badge == 1) {
        
        self.fireEmitter.position = position;
        self.smokeEmitter.position = position;
        
        [self.fireEmitter setValue:[NSNumber numberWithInt:0]
                        forKeyPath:@"emitterCells.fire.birthRate"];
        
        [self.smokeEmitter setValue:[NSNumber numberWithInt:0]
                        forKeyPath:@"emitterCells.smoke.birthRate"];
    }
    
    float diff = badge/5.0;
    float percentage = MAX(MIN(diff, 1.0), 0.1);
    
    [self setFireAmount:2 * percentage];
    
    [CATransaction commit];
}

- (void) setFireAmount:(float)zeroToOne
{
    
    CABasicAnimation *burst1 = [CABasicAnimation animationWithKeyPath:@"emitterCells.fire.birthRate"];
    burst1.fromValue            = [NSNumber numberWithInt:(zeroToOne * 100)];   // short but intense burst
    burst1.toValue            = [NSNumber numberWithFloat: 0.0];        // each birth creates 20 aditional cells!
    burst1.duration            = 0.5;
    burst1.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [self.fireEmitter addAnimation:burst1 forKey:@"burst"];
                                  
	[self.fireEmitter setValue:[NSNumber numberWithFloat:zeroToOne]
					forKeyPath:@"emitterCells.fire.lifetime"];
	[self.fireEmitter setValue:[NSNumber numberWithFloat:(zeroToOne * 0.35)]
					forKeyPath:@"emitterCells.fire.lifetimeRange"];
	self.fireEmitter.emitterSize = CGSizeMake(4 * zeroToOne, 0);
                                   
	[self.smokeEmitter setValue:[NSNumber numberWithInt:zeroToOne * 4]
					 forKeyPath:@"emitterCells.smoke.lifetime"];
	[self.smokeEmitter setValue:(id)[[UIColor colorWithRed:1 green:1 blue:1 alpha:zeroToOne * 0.3] CGColor]
					 forKeyPath:@"emitterCells.smoke.color"];
}


@end


