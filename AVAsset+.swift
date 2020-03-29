//
//  AVAsset+.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension AVAsset {
    func getThumbnails(size: CGSize, completionHandler: @escaping (_ images: [UIImage]) -> Void) {
        var images:[UIImage] = []
        var times:[NSValue] = []
        
        // 320 / 30
        var i:Int64 = 0
        let count = Int64(UIScreen.main.bounds.width/size.width)
        while(i < count) {
            let interval:Int64 = self.duration.value/count
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
    
    func getDuration(completion: @escaping (_ time: CMTime) -> Void) {
        self.loadValuesAsynchronously(forKeys: ["duration"]) {
            switch(self.statusOfValue(forKey: "duration", error: nil)) {
            case AVKeyValueStatus.loaded:
                completion(self.duration)
                
                break
            default:
                break
            }
        }
        
        
    }
    
    func getSize() -> CGSize {
        guard let track = self.tracks(withMediaType: AVMediaTypeVideo).first else { return CGSize.zero }
        let size = track.naturalSize.applying(track.preferredTransform)
        
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }

}
