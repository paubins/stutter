//
//  UIButton+.swift
//  Stutter
//
//  Created by Patrick Aubin on 11/10/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import FontAwesomeKit
import Cartography

extension UIButton {
    static func backButton() -> UIButton {
        let arrowLeft:FAKFontAwesome = FAKFontAwesome.arrowLeftIcon(withSize: 30)
        arrowLeft.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.white)
        
        let image:UIImage = arrowLeft.image(with: CGSize(width: 30, height: 40)).addShadow()
        let imageView:UIImageView = UIImageView(image: image)
        let containerView:UIButton = UIButton(type: .custom)
        containerView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        containerView.addSubview(imageView)
        
        constrain(imageView) { (view) in
            view.centerY == view.superview!.centerY
            view.centerX == view.superview!.centerX
        }
        
        return containerView
    }
    
    static func nextButton() -> UIButton {
        let arrowRight:FAKFontAwesome = FAKFontAwesome.arrowRightIcon(withSize: 30)
        arrowRight.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.white)
        
        let image:UIImage = arrowRight.image(with: CGSize(width: 30, height: 40)).addShadow()
        let imageView:UIImageView = UIImageView(image: image)
        
        let containerView:UIButton = UIButton(type: .custom)
        containerView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        containerView.addSubview(imageView)

        constrain(imageView) { (view) in
            view.centerY == view.superview!.centerY
            view.centerX == view.superview!.centerX
        }
        
        return containerView
    }
    
    static func saveButton() -> UIButton {
        let arrowRight:FAKFontAwesome = FAKFontAwesome.saveIcon(withSize: 30)
        arrowRight.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.white)
        
        let image:UIImage = arrowRight.image(with: CGSize(width: 30, height: 40)).addShadow()
        let imageView:UIImageView = UIImageView(image: image)
        let containerView:UIButton = UIButton(type: .custom)
        containerView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        containerView.addSubview(imageView)
        
        constrain(imageView) { (view) in
            view.centerY == view.superview!.centerY
            view.centerX == view.superview!.centerX
        }
        
        return containerView
    }
    
    static func bookButton() -> UIButton {
        let playStopBackButton:UIButton = UIButton(type: .custom)
        let bookIcon:FAKFontAwesome = FAKFontAwesome.bookIcon(withSize: 30)
        bookIcon.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.white)
        
        playStopBackButton.setImage(bookIcon.image(with: CGSize(width: 30
            , height: 40)).addShadow(), for: .normal)
        return playStopBackButton
    }
}
