//
//  AudioExporter.m
//  Stutter
//
//  Created by Patrick Aubin on 6/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

#import "AudioExporter.h"

@implementation AudioExporter

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (NSURL *)getAudioFromVideo:(AVAsset *)asset audioURL:(NSURL *)audioURL handler:(void (^)(AVAssetExportSession*))handler {
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    AVAssetTrack *videoAsset3Track = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTime duration = videoAsset3Track.timeRange.duration;
    
    exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    exportSession.outputURL = audioURL;
    exportSession.outputFileType = AVFileTypeCoreAudioFormat;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[audioURL path]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[audioURL path] error:nil];
    }
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed -> Reason: %@, User Info: %@",
                      exportSession.error.localizedDescription,
                      exportSession.error.userInfo.description);
                break;
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export cancelled");
                break;
                
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export finished");

                
                NSLog(@"AudioLocation : %@", audioURL.path);
                break;
                
            default:
                break;
                
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(exportSession);
        });
    }];
    
    return audioURL;
}

@end
