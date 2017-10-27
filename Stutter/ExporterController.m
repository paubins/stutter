//
//  ExporterController.m
//  FakeFaceTime
//
//  Created by Patrick Aubin on 7/7/17.
//  Copyright © 2017 com.paubins.FakeFaceTime. All rights reserved.
//

#import "ExporterController.h"


@implementation ExporterController

+ (AVAssetExportSession *)export:(AVMutableComposition *)mixComposition videoAsset:(AVAsset *)videoAsset fromOutput:(NSURL *)outputFileURL {
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
    [layerInstruction setOpacity:0.0 atTime:videoAsset.duration];
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
                 break;
             }
             case AVAssetExportSessionStatusCompleted:{
                 NSLog(@"Success");
                 break;
             }
                 
             default:
                 break;
         }
         
     }       
     ];
    
    return assetExport;
}

+ (void) overlapVideos {
    
    //First load your videos using AVURLAsset. Make sure you give the correct path of your videos.
    
    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]] options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]] options:nil];
    
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our multiple videos.
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    //Now we are creating the first AVMutableCompositionTrack containing our first video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //Now we set the length of the firstTrack equal to the length of the firstAsset and add the firstAsset to out newly created track at kCMTimeZero so video plays from the start of the track.
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Repeat the same process for the 2nd track as we did above for the first track.
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //See how we are creating AVMutableVideoCompositionInstruction object. This object will contain the array of our AVMutableVideoCompositionLayerInstruction objects. You set the duration of the layer. You should add the length equal to the length of the longer asset in terms of duration.
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    
    //We will be creating 2 AVMutableVideoCompositionLayerInstruction objects. Each for our 2 AVMutableCompositionTrack. Here we are creating AVMutableVideoCompositionLayerInstruction for out first track. See how we make use of Affinetransform to move and scale our First Track. So it is displayed at the bottom of the screen in smaller size.(First track in the one that remains on top).
    //Note: You have to apply transformation to scale and move according to your video size.
    
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.6f,0.6f);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(320,320);
    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
    
    //Here we are creating AVMutableVideoCompositionLayerInstruction for our second track.see how we make use of Affinetransform to move and scale our second Track.
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
    CGAffineTransform SecondScale = CGAffineTransformMakeScale(0.9f,0.9f);
    CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    
    //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    //Now we create AVMutableVideoComposition object.We can add multiple AVMutableVideoCompositionInstruction to this object.We have only one AVMutableVideoCompositionInstruction object in our example.You can use multiple AVMutableVideoCompositionInstruction objects to add multiple layers of effects such as fade and transition but make sure that time ranges of the AVMutableVideoCompositionInstruction objects dont overlap.
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:@"overlapVideo.mov"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self exportDidFinish:exporter];
        });
    }];
}


@end
