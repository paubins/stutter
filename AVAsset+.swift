//
//  AVAsset+.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension AVAsset {
    func getThumbnails(completionHandler: @escaping (_ images: [UIImage]) -> Void) {
        var images:[UIImage] = []
        var times:[NSValue] = []
        
        // 320 / 30
        var i:Int64 = 0
        while(i < 10) {
            let interval:Int64 = self.duration.value/Int64(10)
            times.append(NSValue(time: CMTimeMake(interval * i, self.duration.timescale)))
            i += 1
        }
        
        i = 0
        let assetGenerator:AVAssetImageGenerator = AVAssetImageGenerator(asset: self)
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            images.append(UIImage(cgImage: image!))
            
            if (i == times.count-1) {
                completionHandler(images)
            } else {
                i += 1
            }
        }
    }
    
    func getAudio(completion: @escaping (_ time: CMTime, _ url: URL) -> Void) {
        self.loadValuesAsynchronously(forKeys: ["duration"]) {
            switch(self.statusOfValue(forKey: "duration", error: nil)) {
            case AVKeyValueStatus.loaded:
                let composition:AVMutableComposition = AVMutableComposition()
                
                var videoTrack2: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0)
                var audioTrack2: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                
                var videoAssetTracks2: [Any] = self.tracks(withMediaType: AVMediaTypeVideo)
                var audioAssetTracks2: [Any] = self.tracks(withMediaType: AVMediaTypeAudio)
                
                var videoAssetTrack2 = (videoAssetTracks2.count > 0 ? videoAssetTracks2[0] as? AVAssetTrack : nil)
                try? videoTrack2?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (videoAssetTrack2?.timeRange.duration)!), of: videoAssetTrack2!, at: kCMTimeZero)
                
                var audioAssetTrack2 = (audioAssetTracks2.count > 0 ? audioAssetTracks2[0] as? AVAssetTrack : nil)
                try? audioTrack2?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (audioAssetTrack2?.timeRange.duration)!), of: audioAssetTrack2!, at: kCMTimeZero)
                
                AudioExporter.getAudioFromVideo(self, composition: composition) { (exportSession) in
                    let url:URL = (exportSession?.outputURL)!
                    
                    completion((videoAssetTrack2?.timeRange.duration)!, url)
                }
                
                break
            default:
                break
            }
        }
        
        
    }
}
