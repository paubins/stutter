//
//  CIImage+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/12/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension CIImage {
    convenience init(buffer: CMSampleBuffer) {
        self.init(cvPixelBuffer: CMSampleBufferGetImageBuffer(buffer)!)
    }
}
