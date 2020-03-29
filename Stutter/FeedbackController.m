//
//  FeedbackController.m
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/13/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

#import "FeedbackController.h"
#import "Doorbell/Doorbell.h"

@implementation FeedbackController

+ (void)showFeedback:(UIViewController *)viewController
{
    NSString *appId = @"6588";
    NSString *appKey = @"A0xlWA3lJZH2uyaXMVhY4dPtIKOfV7gdjlEVZLJ6nlAvsm46394nbdRfVK4vFluV";
    
    Doorbell *feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
    feedback.email = @"patrick@ew.email";
    feedback.name = @"Lil Stutter";
    feedback.showEmail = NO;
//    [feedback addPropertyWithName:@"username" AndValue:@"manavo"];
    [feedback showFeedbackDialogInViewController:viewController completion:^(NSError *error, BOOL isCancelled) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
