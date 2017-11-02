//
//  MainCollectionView.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/1/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class MainCollectionView : UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
