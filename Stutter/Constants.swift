//
//  Constants.swift
//  Stutter
//
//  Created by Patrick Aubin on 6/27/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import FontAwesomeKit

let WIDTH_CONSTANT = CGFloat(10.0)

struct Constant {
    static let scrubberFramePreviewHeight:CGFloat = 60.0
    static let NUMBER_OF_FRAME = 10
    static let wavesColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    static let scrubberViewHeight:CGFloat = 50
    static let COLORS = [UIColor(rgbColorCodeRed: 170, green: 255, blue: 3, alpha: 1.0),
                                     UIColor(rgbColorCodeRed: 255, green: 170, blue: 3, alpha: 1.0),
                                     UIColor(rgbColorCodeRed: 255, green: 0, blue: 170, alpha: 1.0),
                                     UIColor(rgbColorCodeRed: 170, green: 1, blue: 255, alpha: 1.0),
                                     UIColor(rgbColorCodeRed: 0, green: 170, blue: 255, alpha: 1.0)]
    static let scrubberSliceDamping:CGFloat = 0.7
    static let scrubberSpringVelocity:CGFloat = 0.8
    
    static let flipperWidthFirst:CGFloat = 5
    static let flipperWidth:CGFloat = 20
    static let flipperPadding:CGFloat = CGFloat(50.0)
    
    static let mainControlHeight:CGFloat = 400.0
    
    static let secondaryControlHeight:CGFloat = Constant.mainControlHeight - 80
    static let secondaryControlHeightControlPoint1:CGFloat = Constant.secondaryControlHeight + 5
    static let secondaryControlHeightControlPoint2:CGFloat = Constant.secondaryControlHeight + 10
    static let secondaryControlDiameter:CGFloat = 10.0
    
    static let primaryControlDiameter:CGFloat = 30.0
    
    static let mainControllCutoffMin:CGFloat = 200.0
    static let mainControllCutoffMax:CGFloat = 5.0
    
    static let tertiaryControlCenterOffset:CGFloat = 150.0
    static let waveformCenterPointOffset:CGFloat = 150.0
    static let thumbnailsCenterPointOffset:CGFloat = 100.0
    
    static let controlSurfaceHeight:CGFloat = 200.0
    
    static func addInset(to point:CGPoint) -> CGPoint {
        return CGPoint(x: point.x - 25,
                       y: point.y - 120)
    }
}

struct ButtonIcons {
    static let downloadImage:UIImage? = FAKFontAwesome.downloadIcon(withSize: 40)?.image(with: CGSize(width: 40, height: 40))
    static let bombImage:UIImage? = FAKFontAwesome.bombIcon(withSize: 40)?.image(with: CGSize(width: 40, height: 40))
}

enum StutterState {
    case prearmed
    case armed
    case recording
    case paused
    case exporting
    case exported
}
