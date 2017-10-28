//
//  ExporterController.m
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/7/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

#import "ExporterController.h"


@implementation ExporterController

+ (AVAssetExportSession *)export:(AVMutableComposition *)mixComposition videoAsset:(AVAsset *)videoAsset fromOutput:(NSURL *)outputFileURL completionHandler:(void (^)(AVAssetExportSession *))completionHandler {
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioComposition = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    //*****************//
    UIImageOrientation videoAssetOrientation_;// = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;

    CGAffineTransform videoTransform = clipVideoTrack.preferredTransform;

    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
        isVideoAssetPortrait_ = NO;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
        isVideoAssetPortrait_ = NO;
    }

    [layerInstruction setTransform:clipVideoTrack.preferredTransform atTime:kCMTimeZero];
//    [layerInstruction setOpacity:0.0 atTime:clipVideoTrack.timeRange.duration];

    //*****************//
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width);
    } else {
        naturalSize = clipVideoTrack.naturalSize;
    }

    NSLog(@"videoSize ++++: %@", NSStringFromCGSize(naturalSize));
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition] ;

    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    videoComp.renderSize = CGSizeMake(renderWidth, renderHeight);
    videoComp.instructions = [NSArray arrayWithObject:instruction];
    videoComp.frameDuration = CMTimeMake(1, 30);

    /// instruction

    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
    assetExport.outputURL = outputFileURL;
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.shouldOptimizeForNetworkUse = NO;
    assetExport.videoComposition = videoComp;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch (assetExport.status) {
             case AVAssetExportSessionStatusFailed:{
                 NSLog(@"Fail");
                 NSLog(@"asset export fail error : %@", assetExport.error);
                 
                 
                 completionHandler(assetExport);
                 
                 break;
             }
             case AVAssetExportSessionStatusCompleted:{
                 NSLog(@"Success");
                 completionHandler(assetExport);
                 break;
             }
                 
             default:
                 break;
         }
         
     }       
     ];
    
    return assetExport;
}


@end
