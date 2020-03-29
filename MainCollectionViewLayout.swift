//
//  MainCollectionViewLayout.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation

class MainCollectionViewLayout: UICollectionViewFlowLayout {
    
//    override var collectionViewContentSize: CGSize{
//        let xSize = CGFloat(self.collectionView!.numberOfItems(inSection: 0)) * self.itemSize.width
//        let ySize = CGFloat(self.collectionView!.numberOfSections) * self.itemSize.height
//        
//        var contentSize = CGSize(width: xSize, height: ySize)
//        
//        if self.collectionView!.bounds.size.width > contentSize.width {
//            contentSize.width = self.collectionView!.bounds.size.width
//        }
//        
//        if self.collectionView!.bounds.size.height > contentSize.height {
//            contentSize.height = self.collectionView!.bounds.size.height
//        }
//        
//        return contentSize
//    }
//    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // unwrap super's attributes
        guard let superArray = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // copy items
        guard let attributesArray = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }

        for attributes in attributesArray {
            let xPosition = attributes.center.x
            var yPosition = attributes.center.y
            
            guard let section = SliderSections(rawValue: attributes.indexPath.section) else {
                assertionFailure()
                return [UICollectionViewLayoutAttributes(forCellWith: attributes.indexPath)]
            }
            
            switch(section) {
            case .slices:
                attributes.zIndex = 90
                attributes.center = CGPoint(x: xPosition, y: yPosition)
                break
            case .buttons:
                yPosition -= Constant.tertiaryControlCenterOffset
                attributes.zIndex = 99
                attributes.center = CGPoint(x: xPosition, y: yPosition)
                break
            case .waveform:
                if UIScreen.isPhoneX {
                    yPosition -= Constant.waveformCenterPointOffset - 25
                } else {
                    yPosition -= Constant.waveformCenterPointOffset
                }
                
                attributes.zIndex = 80
                attributes.center = CGPoint(x: xPosition, y: yPosition)
                break
            case .thumbnails:
                if UIScreen.isPhoneX {
                    yPosition -= Constant.waveformCenterPointOffset - 25
                } else {
                    yPosition -= Constant.thumbnailsCenterPointOffset
                }
                
                attributes.zIndex = 70
                attributes.center = CGPoint(x: xPosition, y: yPosition)
                break
            default:
                break
            }
        }
        
        return attributesArray
    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        guard let section = SliderSections(rawValue: indexPath.section) else {
//            assertionFailure()
//            return UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        }
//        
//        let kWhateverHeightYouWant = 50
//        let layoutAttributes:UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: indexPath)!
//        
//        switch(section) {
//        case .buttons:
//            let xPosition = layoutAttributes.center.x
//            let yPosition = layoutAttributes.center.y
//            layoutAttributes.center = CGPoint(x: xPosition, y: yPosition)
//            break
//        case .slices:
//            return layoutAttributes
//            break
//        case .waveform:
//            let xPosition = layoutAttributes.center.x
//            let yPosition = layoutAttributes.center.y
//            layoutAttributes.center = CGPoint(x: xPosition, y: yPosition)
//            break
//        case .thumbnails:
//            let xPosition = layoutAttributes.center.x
//            let yPosition = layoutAttributes.center.y
//            layoutAttributes.center = CGPoint(x: xPosition, y: yPosition)
//        default:
//            break
//        }
//        
//        return layoutAttributes
//    }
//    
    
}
