//
//  URL+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/9/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension URL {
    static func generateURL(fileExtension: String) -> URL {
        let filename = "\(String.randomString(length: 15)).\(fileExtension)"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try! manager.removeItem(atPath: outputPath)
        }
        
        return fileUrl
    }
}
