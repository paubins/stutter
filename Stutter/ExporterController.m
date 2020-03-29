//
//  ExporterController.m
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/7/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

#import "ExporterController.h"


@implementation ExporterController

+ (AVMutableVideoComposition *)getVideoCompositionFrom:(AVMutableComposition *)mixComposition asset:(AVAsset *)videoAsset extraInstructions:(AVMutableVideoCompositionLayerInstruction *)extraInstructions {
    //    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    //    AVMutableCompositionTrack *audioComposition = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    [layerInstruction setTransform:clipVideoTrack.preferredTransform atTime:kCMTimeZero];
    
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
    videoComp.frameDuration = CMTimeMake(1, 30);
    
    /// instruction
    instruction.layerInstructions = @[extraInstructions];
    videoComp.instructions = @[instruction];
    
    return videoComp;
}

+ (AVAssetExportSession *)export:(AVMutableComposition *)mixComposition videoAsset:(AVAsset *)videoAsset extraInstructions:(AVMutableVideoCompositionLayerInstruction *)extraInstructions fromOutput:(NSURL *)outputFileURL completionHandler:(void (^)(AVAssetExportSession *, BOOL))completionHandler {

    
    AVMutableVideoComposition *videoComp = [self getVideoCompositionFrom:mixComposition asset:videoAsset extraInstructions:extraInstructions];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
    assetExport.outputURL = outputFileURL;
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.shouldOptimizeForNetworkUse = NO;
    assetExport.videoComposition = videoComp;
    assetExport.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch (assetExport.status) {
             case AVAssetExportSessionStatusFailed:{
                 NSLog(@"Fail");
                 NSLog(@"asset export fail error : %@", assetExport.error);
                 
                 completionHandler(assetExport, false);
                 
                 break;
             }
             case AVAssetExportSessionStatusCompleted:{
                 NSLog(@"Success");
                 
                 completionHandler(assetExport, true);
                 
                 break;
             }
                 
             default:
                 break;
         }
         
     }       
     ];
    
    return assetExport;
}

+ (CVPixelBufferRef) rotateBuffer: (CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    //CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, _pixelWriter.pixelBufferPool, &pxbuffer);
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *dest_buff = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(dest_buff != NULL);
    
    int *src = (int*) src_buff ;
    int *dest= (int*) dest_buff ;
    size_t count = (bytesPerRow * height) / 4 ;
    while (count--) {
        *dest++ = *src++;
    }
    
    //Test straight copy.
    //memcpy(pxdata, baseAddress, width * height * 4) ;
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return pxbuffer;
}

@end
