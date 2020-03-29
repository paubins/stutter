//
//  UIImage+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/10/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension UIImage {
    func ipMaskedImageNamed(color:UIColor) -> UIImage {
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0),
                                 size: CGSize(width: self.size.width, height: self.size.height))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        
        let c:CGContext = UIGraphicsGetCurrentContext()!
        
        self.draw(in: rect)

        
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func addShadow(blur: CGFloat = 6.0, shadowColor: UIColor = UIColor(white: 0, alpha: 1), offset: CGSize = CGSize(width: 1, height: 1) ) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + 2 * blur, height: size.height + 2 * blur), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setShadow(offset: offset, blur: blur, color: shadowColor.cgColor)
        draw(in: CGRect(x: blur - offset.width / 2, y: blur - offset.height / 2, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
