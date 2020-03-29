//
//  UIScreen+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/3/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Device

extension UIScreen {
    ///
    static var isPhoneX: Bool {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        return (min(width, height) == 375 && max(width, height) == 812) && !Device.isPad()
    }
}
