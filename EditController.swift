//
//  EditController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import SwiftyTimer

class EditController: NSObject {
    static var shared:EditController! = EditController()
    
    var currentAssetDuration:CMTime {
        get {
            return self.asset.duration
        }
    }

    var lastInsertedTime:CMTime = kCMTimeZero

    var size:CGSize {
        get {
            return self.asset.getSize()
        }
    }
    
    lazy var instructions:AVMutableVideoCompositionLayerInstruction! = {
        let assetTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).first!
        let instruction1:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        
        return instruction1
    }()

    var currentTransform:CGAffineTransform!
    
    var currentEditHandler:((_ endTime:CMTime, _ percentageZoom:CGFloat, _ percentageSpeed:CGFloat) -> CMTime)!
    
    lazy var mutableComposition:AVMutableComposition = {
        let mutableComposition:AVMutableComposition = AVMutableComposition()
        return mutableComposition
    }()
    
    var asset:AVAsset!
    
    func createEditHandler(_ at: CMTime, startTime: CMTime) -> ((_ durationEnd:CMTime, _ percentageZoom:CGFloat, _ percentageSpeed: CGFloat) -> CMTime) {
        var durationStart:CMTime = CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30)
        
        func endTimeHandler(durationEnd: CMTime, percentageZoom: CGFloat, percentageSpeed: CGFloat) -> CMTime {
            var durationInterval:CMTime = CMTimeSubtract(durationEnd, durationStart)
            if (self.currentAssetDuration < CMTimeAdd(startTime, durationInterval)) {
                durationInterval = CMTimeSubtract(self.currentAssetDuration, startTime)
            }

            let timeRange = CMTimeRangeMake(startTime, durationInterval)
            
            // 1. we get the length shown
            // NOTE: They're inverted in logic because if we're sped up, we need
            // that component to be extra long, because the scrubber sped through
            // that section faster than other sections
            do {
                try self.mutableComposition.insertTimeRange(timeRange, of: self.asset, at: at)
            } catch {
                print("something fucked up")
            }
            
            // 3. scale that time range
            if 0.1 <= fabs(percentageSpeed) {
                let offset = percentageSpeed < 0 ? -1 : 1
                if (0 < offset) {
                    durationInterval = CMTimeMultiplyByRatio(durationInterval,
                                                             Int32(fabs(percentageSpeed)*100), 100)
                    self.mutableComposition.scaleTimeRange(CMTimeRangeMake(at, timeRange.duration),
                                                           toDuration: durationInterval)
                    
                } else {
                    durationInterval = CMTimeAdd(durationInterval, CMTimeMultiplyByRatio(durationInterval,
                                                                                         Int32(fabs(percentageSpeed)*100), 100))
                    self.mutableComposition.scaleTimeRange(CMTimeRangeMake(at, timeRange.duration),
                                                           toDuration: durationInterval)
                }
            }
            
            let scaleX:CGFloat = 1 + percentageZoom
            let scaleY:CGFloat = 1 + percentageZoom

            self.currentTransform = (self.asset.tracks(withMediaType: AVMediaTypeVideo).first?.preferredTransform
                .concatenating(CGAffineTransform(scaleX: scaleX, y: scaleY))
                .concatenating(CGAffineTransform(translationX: -(self.size.width * percentageZoom)/2,
                                                 y: -(self.size.height * percentageZoom)/2)))!
            
            if (self.instructions == nil) {
                let assetTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).first!
                self.instructions = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
            }
            
            self.instructions.setTransform(self.currentTransform, at: at)
            
            return CMTimeAdd(at, durationInterval)
        }
        
        return endTimeHandler
    }
    
    func closeEdit() {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = kCMTimeZero
            let _ = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30), 0, 0)
            self.currentEditHandler = nil
        }
    }
    
    func storeEdit(percentageOfTime: CGFloat, percentageZoom: CGFloat, percentageSpeed: CGFloat)  -> CMTime {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30), percentageZoom, percentageSpeed)
        }
        
        let time:CMTime = self.secondsFrom(percentage: percentageOfTime)
        self.currentEditHandler = self.createEditHandler(self.lastInsertedTime, startTime: time)
        return time
    }

    
    func export(completionHandler: @escaping (Bool) -> Void) throws -> AVAssetExportSession {
        let filename = "\(String.randomString(length: 15)).mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        return ExporterController.export(self.mutableComposition, videoAsset: self.asset,
                                         extraInstructions: self.instructions,
                                         fromOutput: fileUrl, completionHandler: { (assetExportSession, success) in
            self.mutableComposition = AVMutableComposition()
            self.instructions = AVMutableVideoCompositionLayerInstruction()
            completionHandler(success)
        })
    }
    
    func getVideoComposition() -> AVVideoComposition {
        return ExporterController.getVideoComposition(from: self.mutableComposition, asset: self.asset, extraInstructions: self.instructions)
    }

    func secondsFrom(percentage: CGFloat) -> CMTime {
        return CMTimeMakeWithSeconds(CMTimeGetSeconds(self.currentAssetDuration) * Float64(percentage), 30)
    }
    
    func load(url: URL) {
        self.asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    }
    
    func reset() {
        self.mutableComposition = AVMutableComposition()
        self.lastInsertedTime = kCMTimeZero
        self.currentEditHandler = nil
        self.instructions = nil
    }
}
