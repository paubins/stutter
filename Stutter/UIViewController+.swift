//
//  UIViewController+.swift
//  Stutter
//
//  Created by Patrick Aubin on 6/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

extension UIViewController {
    public func dch_checkDeallocation(afterDelay delay: TimeInterval = 2.0) {
        let rootParentViewController = dch_rootParentViewController
        
        // We don’t check `isBeingDismissed` simply on this view controller because it’s common
        // to wrap a view controller in another view controller (e.g. in UINavigationController)
        // and present the wrapping view controller instead.
        if isMovingFromParentViewController || rootParentViewController.isBeingDismissed {
            let type = type(of: self)
            let disappearanceSource: String = isMovingFromParentViewController ? "removed from its parent" : "dismissed"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                assert(self == nil, "\(type) not deallocated after being \(disappearanceSource)")
            })
        }
    }
    
    private var dch_rootParentViewController: UIViewController {
        var root = self
        
        while let parent = root.parent {
            root = parent
        }
        
        return root
    }
}
