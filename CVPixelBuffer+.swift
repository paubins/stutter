//
//  CVPixelBuffer+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/12/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension CVPixelBuffer {
    func deepcopy() -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let format = CVPixelBufferGetPixelFormatType(self)
        var pixelBufferCopyOptional:CVPixelBuffer?
        CVPixelBufferCreate(nil, width, height, format, nil, &pixelBufferCopyOptional)
        if let pixelBufferCopy = pixelBufferCopyOptional {
            CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
            CVPixelBufferLockBaseAddress(pixelBufferCopy, CVPixelBufferLockFlags(rawValue: 0))
            let baseAddress = CVPixelBufferGetBaseAddress(self)
            let dataSize = CVPixelBufferGetDataSize(self)
            print("dataSize: \(dataSize)")
            let target = CVPixelBufferGetBaseAddress(pixelBufferCopy)
            memcpy(target, baseAddress, dataSize)
            CVPixelBufferUnlockBaseAddress(pixelBufferCopy, CVPixelBufferLockFlags(rawValue: 0))
            CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
        }
        return pixelBufferCopyOptional
    }
    
//    func resize(_ destSize: CGSize)-> CVPixelBuffer? {
//        // Lock the image buffer
////        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
////        // Get information about the image
////        let baseAddress = CVPixelBufferGetBaseAddress(self)
////        let bytesPerRow = CGFloat(CVPixelBufferGetBytesPerRow(self))
////        let height = CGFloat(CVPixelBufferGetHeight(self))
////        let width = CGFloat(CVPixelBufferGetWidth(self))
////        var pixelBuffer: CVPixelBuffer?
////        let options = [kCVPixelBufferCGImageCompatibilityKey:true,
////                       kCVPixelBufferCGBitmapContextCompatibilityKey:true]
////        
////        let topMargin = (height - destSize.height) / CGFloat(2)
////        let leftMargin = (width - destSize.width) * CGFloat(2)
////        
////        var baseAddressStart = 0 // Int(bytesPerRow * topMargin + leftMargin)
////        var addressPoint = baseAddress!.assumingMemoryBound(to: UInt8.self)
////        
////        var baseAddress2 = UnsafeMutableRawPointer.allocate(bytes: Int(width*height*2), alignedTo: 2)
////        var addressPoint2 = baseAddress2.assumingMemoryBound(to: UInt8.self)
////        
////        for row in 0...Int(100) {
////            for column in 0...Int(100) {
////                addressPoint2[0] = addressPoint[row*column][0]
////                addressPoint2[1] = addressPoint[row*column][1]
////                addressPoint2[2] = addressPoint[row*column][2]
////                addressPoint2   [3] = addressPoint[row*column][3]
////            }
////        }
//
////        baseAddressStart = 0
////        addressPoint = baseAddress!.assumingMemoryBound(to: UInt8.self)
////
//        let status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, Int(100), Int(100), kCVPixelFormatType_32BGRA, &addressPoint2[baseAddressStart], Int(bytesPerRow), nil, nil, options as CFDictionary, &pixelBuffer)
//        
//        if (status != 0) {
//            print(status)
//            return nil;
//        }
//        
//        CVPixelBufferUnlockBaseAddress(self,CVPixelBufferLockFlags(rawValue: 0))
//        return pixelBuffer;
//    }
}
