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
    var currentPlayTimeInSeconds:CMTime = .zero
    var currentPlayTimer:Timer!
    var currentAssetDuration:CMTime = .zero
    var lastSelectedIndex:Int = 0
    var lastInsertedTime:CMTime = .zero
    var started:Bool = true
    var previousFrameRelativeStartTime:Float64!
    var previousFrameTime:CFTimeInterval!
    var currentMediaTime:CFTimeInterval!
    var currentInterval:CFTimeInterval!
    var size:CGSize = CGSize.zero
    
    var mainInstruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
    lazy var instructions:AVMutableVideoCompositionLayerInstruction = {
        let assetTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).first!
        let instruction1:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        return instruction1
    }()
    
    lazy var currentTransform:CGAffineTransform = {
        let assetTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).first!
        
        return assetTrack.preferredTransform
    }()
    
    var exporter:AVAssetExportSession! = nil
    
    var originalVolume:Float = 0
    
    var currentEditHandler:((_ endTime:CMTime, _ percentageZoom:CGFloat) -> CMTime)!
    
    lazy var mutableComposition:AVMutableComposition = {
        let mutableComposition:AVMutableComposition = AVMutableComposition()
        
        return mutableComposition
    }()
    
    var asset:AVAsset!
    var timer:Timer!
    
    init(asset: AVAsset) {
        super.init()
        self.asset = AVURLAsset(url: (asset as! AVURLAsset).url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    }
    
    func createEditHandler(_ at: CMTime, startTime: CMTime) -> ((_ durationEnd:CMTime, _ percentageZoom:CGFloat) -> CMTime) {
        var durationStart:CMTime = CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30)
        
        func endTimeHandler(durationEnd: CMTime, percentageZoom: CGFloat) -> CMTime {
            let durationInterval:CMTime = CMTimeSubtract(durationEnd, durationStart)
            let timeRange = CMTimeRangeMake(start: startTime, duration: durationInterval)
            do {
                print(at.value)
                try self.mutableComposition.insertTimeRange(timeRange, of: self.asset, at: at)
            } catch {
                print("something fucked up")
            }
            
            let scaleX:CGFloat = 1 + percentageZoom
            let scaleY:CGFloat = 1 + percentageZoom
            
            

            self.instructions.setTransform(self.currentTransform
                .concatenating(CGAffineTransform(scaleX: scaleX, y: scaleY))
                .concatenating(CGAffineTransform(translationX: -(self.size.width * percentageZoom)/2, y: -(self.size.height * percentageZoom)/2)),
                                           at: at)
            
            return CMTimeAdd(at, timeRange.duration)
        }
        
        return endTimeHandler
    }
    
    func closeEdit() {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = kCMTimeZero
            let _ = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30), 0)
            self.currentEditHandler = nil
        }
    }
    
    func storeEdit(percentageOfTime: CGFloat, percentageZoom: CGFloat)  -> CMTime {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 30), percentageZoom)
        }
        
        let time:CMTime = self.secondsFrom(percentage: percentageOfTime)
        
        self.currentEditHandler = self.createEditHandler(self.lastInsertedTime, startTime: time)
        
        return time
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func export(completionHandler: @escaping (Bool) -> Void) throws -> AVAssetExportSession {
        let filename = "\(self.randomString(length: 15)).mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        print(outputPath)
        
        return ExporterController.export(self.mutableComposition, videoAsset: self.asset,
                                         extraInstructions: self.instructions,
                                         fromOutput: fileUrl, completionHandler: { (assetExportSession, success) in
            self.mutableComposition = AVMutableComposition()
            completionHandler(success)
        })
    }
    
    func load(duration: CMTime, size: CGSize) {
        self.currentAssetDuration = duration
        self.size = size
    }
    
    func secondsFrom(percentage: CGFloat) -> CMTime {
        return CMTimeMakeWithSeconds(CMTimeGetSeconds(self.currentAssetDuration) * Float64(percentage), preferredTimescale: 60)
    }
}
