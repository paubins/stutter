//
//  PlayButtonsView.swift
//  Stutter
//
//  Created by Patrick Aubin on 5/22/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import UIKit
import SwiftyButton

protocol PlayButtonViewDelegate {
    func playButtonWasTapped(index: Int)
    func badgedEarned(badge: Int, index: Int)
}

let COLORS:[UIColor] = [UIColor(rgbColorCodeRed: 135, green: 135, blue: 135, alpha: 1.0),
                        UIColor(rgbColorCodeRed: 105, green: 105, blue: 198, alpha: 1.0),
                        UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                        UIColor(rgbColorCodeRed: 45, green: 45, blue: 89, alpha: 1.0),
                        UIColor(rgbColorCodeRed: 73, green: 73, blue: 73, alpha: 1.0)
                        ]

class PlayButtonsView: UIView {
    
    let padding = 0
    
    let button0:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.colors = .init(button: COLORS[0],
                                  shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    let button1:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.colors = .init(button: COLORS[1],
                              shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    let button2:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.colors = .init(button: COLORS[2],
                              shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    let button3:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.colors = .init(button: COLORS[3],
                              shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let button4:PressableButton = {
        let button:PressableButton = PressableButton(frame: CGRect.zero)
        button.colors = .init(button: COLORS[4],
                              shadow: .white)
        button.shadowHeight = 2
        button.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    var buttonScores:[Int] = [0, 0, 0, 0, 0] {
        didSet(newScores) {
            for (index, score) in newScores.enumerated() {
                if 25 < score {
                    self.delegate?.badgedEarned(badge: 5, index: index)
                } else if 15 < score {
                    self.delegate?.badgedEarned(badge: 4, index: index)
                } else if 10 < score {
                    self.delegate?.badgedEarned(badge: 3, index: index)
                } else if 5 < score {
                    self.delegate?.badgedEarned(badge: 2, index: index)
                } else if 3 < score {
                    self.delegate?.badgedEarned(badge: 1, index: index)
                }
            }
        }
    }
    
    let colors = [UIColor(rgbColorCodeRed: 135, green: 135, blue: 135, alpha: 1.0),
                  UIColor(rgbColorCodeRed: 105, green: 105, blue: 198, alpha: 1.0),
                  UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                  UIColor(rgbColorCodeRed: 45, green: 45, blue: 89, alpha: 1.0),
                  UIColor(rgbColorCodeRed: 73, green: 73, blue: 73, alpha: 1.0)]
    
    var delegate: PlayButtonViewDelegate?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear
        
        let view:UIView = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self.button0)
        view.addSubview(self.button1)
        view.addSubview(self.button2)
        view.addSubview(self.button3)
        view.addSubview(self.button4)
        
        self.addSubview(view)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        view.clipsToBounds = false
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        } else {
            view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let spacer = UIView(frame: .zero)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)
        
        spacer.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        spacer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        button0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button0.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        button0.leftAnchor.constraint(equalTo: spacer.rightAnchor).isActive = true
        
        let spacer0 = UIView(frame: .zero)
        spacer0.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer0)
        
        spacer0.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer0.leftAnchor.constraint(equalTo: button0.rightAnchor).isActive = true
        
        button1.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button1.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        button1.leftAnchor.constraint(equalTo: spacer0.rightAnchor).isActive = true
        
        let spacer1 = UIView(frame: .zero)
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer1)
        
        spacer1.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer1.leftAnchor.constraint(equalTo: button1.rightAnchor).isActive = true
        
        button2.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button2.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        button2.leftAnchor.constraint(equalTo: spacer1.rightAnchor).isActive = true
        
        let spacer2 = UIView(frame: .zero)
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer2)
        
        spacer2.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer2.leftAnchor.constraint(equalTo: button2.rightAnchor).isActive = true

        button3.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button3.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        button3.leftAnchor.constraint(equalTo: spacer2.rightAnchor).isActive = true
        
        let spacer3 = UIView(frame: .zero)
        spacer3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer3)
        
        spacer3.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer3.leftAnchor.constraint(equalTo: button3.rightAnchor).isActive = true
        
        button4.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button4.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        button4.leftAnchor.constraint(equalTo: spacer3.rightAnchor).isActive = true
        
        let spacer4 = UIView(frame: .zero)
        spacer4.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer4)
        
        spacer4.widthAnchor.constraint(equalToConstant: 3).isActive = true
        spacer4.leftAnchor.constraint(equalTo: button4.rightAnchor).isActive = true
        spacer4.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        button0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        button1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        button2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        button3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        button4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped)))
        
        button0.widthAnchor.constraint(equalTo: button1.widthAnchor, multiplier: 1, constant: 0).isActive = true
        button1.widthAnchor.constraint(equalTo: button2.widthAnchor, multiplier: 1, constant: 0).isActive = true
        button2.widthAnchor.constraint(equalTo: button3.widthAnchor, multiplier: 1, constant: 0).isActive = true
        button3.widthAnchor.constraint(equalTo: button4.widthAnchor, multiplier: 1, constant: 0).isActive = true
    }
    
    func buttonCenter(atIndex: Int) -> CGPoint {
        
        let widthOffset = button0.frame.size.width/2
        let heightOffset = button0.frame.size.height/2
        
        switch atIndex {
        case 0:
            return CGPoint(x: button0.frame.origin.x + widthOffset, y: self.frame.origin.y + heightOffset)
        case 1:
            return CGPoint(x: button1.frame.origin.x + widthOffset, y: self.frame.origin.y + heightOffset)
        case 2:
            return CGPoint(x: button2.frame.origin.x + widthOffset, y: self.frame.origin.y + heightOffset)
        case 3:
            return CGPoint(x: button3.frame.origin.x + widthOffset, y: self.frame.origin.y + heightOffset)
        case 4:
            return CGPoint(x: button4.frame.origin.x + widthOffset, y: self.frame.origin.y + heightOffset)
        default:
            return CGPoint(dictionaryRepresentation: 0.0 as! CFDictionary)!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlayButtonsView {
    
    func tapped(gesturerecognizer:UITapGestureRecognizer) {
        let tappedView = gesturerecognizer.view
        if (tappedView == self.button0) {
            self.buttonScores[0] += 1
            self.delegate?.playButtonWasTapped(index: 0)
        } else if (tappedView == self.button1) {
            self.buttonScores[1] += 1
            self.delegate?.playButtonWasTapped(index: 1)
        } else if (tappedView == self.button2) {
            self.buttonScores[2] += 1
            self.delegate?.playButtonWasTapped(index: 2)
        } else if (tappedView == self.button3) {
            self.buttonScores[3] += 1
            self.delegate?.playButtonWasTapped(index: 3)
        } else if (tappedView == self.button4) {
            self.buttonScores[4] += 1
            self.delegate?.playButtonWasTapped(index: 4)
        }
    }
}
