//
//  ExporterController.h
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/7/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface ExporterController : NSObject

+ (AVAssetExportSession *)export:(AVMutableComposition *)mixComposition videoAsset:(AVAsset *)videoAsset extraInstructions:(AVMutableVideoCompositionLayerInstruction *)extraInstructions fromOutput:(NSURL *)outputFileURL completionHandler:(void (^)(AVAssetExportSession *, BOOL))completionHandler;

@end
