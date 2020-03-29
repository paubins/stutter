//
//  MainCollectionView.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/1/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class MainCollectionView : UICollectionView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("Passing all touches to the next view (if any), in the view stack.")
        return false
    }
}
