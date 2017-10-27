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
    var currentPlayTimeInSeconds:CMTime = kCMTimeZero
    var currentPlayTimer:Timer!
    var currentAssetDuration:Float64 = 0
    var lastSelectedIndex:Int = 0
    var lastInsertedTime:CMTime = kCMTimeZero
    var started:Bool = true
    var previousFrameRelativeStartTime:Float64!
    var previousFrameTime:CFTimeInterval!
    var currentMediaTime:CFTimeInterval!
    var currentInterval:CFTimeInterval!
    
    var exporter:AVAssetExportSession! = nil
    
    var originalVolume:Float = 0
    
    var currentEditHandler:((_ endTime:CMTime) -> CMTime)!
    
    var mutableComposition:AVMutableComposition = AVMutableComposition()
    var asset:AVAsset!
    
    var timer:Timer!
    
    init(asset: AVAsset) {
        super.init()
        
        self.asset = asset
    }
    
    func createEditHandler(_ at: CMTime, startTime: CMTime) -> ((_ durationEnd:CMTime) -> CMTime) {
        var durationStart:CMTime = CMTimeMakeWithSeconds(CACurrentMediaTime(), 600)
        
        func endTimeHandler(durationEnd: CMTime) -> CMTime {
            let durationInterval:CMTime = CMTimeSubtract(durationEnd, durationStart)
            let timeRange = CMTimeRangeMake(startTime, durationInterval)
            print("at: \(at) range: \(timeRange)")
            do {
                try self.mutableComposition.insertTimeRange(timeRange, of: self.asset, at: at)
            } catch {
                print("something fucked up")
            }
            
            return CMTimeAdd(at, timeRange.duration)
        }
        
        return endTimeHandler
    }
    
    func closeEdit() {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = kCMTimeZero
            let _ = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), 600))
            self.currentEditHandler = nil
        }
    }
    
    func storeEdit(time: CMTime) {
        if (self.currentEditHandler != nil) {
            self.lastInsertedTime = self.currentEditHandler(CMTimeMakeWithSeconds(CACurrentMediaTime(), 600))
        }
        
        self.currentEditHandler = self.createEditHandler(self.lastInsertedTime, startTime: time)
    }
    
    func exportSession() -> AVAssetExportSession {
        let assetVideoTrack:AVAssetTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).last!
        let videoCompositonTrack:AVMutableCompositionTrack = self.mutableComposition.tracks(withMediaType: AVMediaTypeVideo).last!
        videoCompositonTrack.preferredTransform = self.asset.preferredTransform
        
        return try! self.export(asset: self.mutableComposition)
    }
    
    private func export(asset: AVAsset) throws -> AVAssetExportSession {        
        let exporter:AVAssetExportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        
        let filename = "composition.mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.outputURL = fileUrl
        
        exporter.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                if exporter.status == AVAssetExportSessionStatus.completed {
                    print("Success")
                }
                else {
                    print(exporter.error?.localizedDescription ?? "error")
                    //The requested URL was not found on this server.
                }
            })
        })
        
        return exporter
    }
    
    func load(time: Float64) {
        self.currentAssetDuration = time
    }
    
    func secondsFrom(percentage: CGFloat) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(CGFloat(self.currentAssetDuration) * percentage), 60)
    }
}
