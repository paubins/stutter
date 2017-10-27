//
//  MainControlViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/26/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import Player
import Device

protocol MainControlViewControllerDelegate {
    func playerButtonWasTapped(index: Int)
    func sliceWasMoved(index: Int,distance: Int)
    func draggingHasBegun(index: Int)
    func draggingHasEnded(index: Int)
}

class MainControlViewController : UIViewController {

    var delegate:MainControlViewControllerDelegate!
    
    lazy var scrubberView:ScrubberView = {
        let scrubberView:ScrubberView = ScrubberView(frame: CGRect.zero)
        scrubberView.delegate = self
        return scrubberView
    }()
    
    lazy var playButtonsView:PlayButtonsView = {
        let playButtonsView:PlayButtonsView = PlayButtonsView(frame: CGRect.zero)
        playButtonsView.delegate = self
        
        return playButtonsView
    }()
    
    let bezierView:UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var recordButtonView:RecordButtonsView = {
        return RecordButtonsView(frame: CGRect.zero)
    }()
    
    var path:UIBezierPath!
    
    var bezierViewControllers:[BezierViewController] = []
    let dazzleController:DazTouchController = DazTouchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.view.addSubview(self.dazzleController.view)
        
        self.view.addSubview(self.bezierView)
        self.view.addSubview(self.recordButtonView)
        self.view.addSubview(self.playButtonsView)
        self.view.addSubview(self.scrubberView)
        
        constrain(self.dazzleController.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.playButtonsView) { (view) in
            view.left == view.superview!.left
            view.right == view.superview!.right
            
            if(UIDevice.current.userInterfaceIdiom == .pad) {
                view.height == 100
            } else {
                view.height == 50
            }
        }
        
        constrain(self.recordButtonView, self.playButtonsView) { (view, view2) in
            view.height == 50
            view.bottom == view2.top
            view.left == view.superview!.left
            view.right == view.superview!.right
        }
        
        constrain(self.scrubberView, self.playButtonsView) { (view, view2) in
            view.top == view2.bottom + 10
        }
        
        constrain(self.scrubberView) { (view) in
            view.height == 50
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.bezierView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        self.scrubberView.delegate = self
        self.playButtonsView.delegate = self
        self.recordButtonView.delegate = self
        
        for index in 0..<5 {
            let slicePositionX:CGFloat = self.scrubberView.getSlicePosition(index: index)
            let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
            
            let viewController:BezierViewController = BezierViewController(points: self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY), with: Constant.COLORS[index])
            self.bezierViewControllers.append(viewController)
            self.bezierView.addSubview(viewController.view)
        }
    }
    
    func orientationChange(notification: Notification) {
        self.scrubberView.setNeedsDisplay()
        
        for (i, bezierViewController) in  self.bezierViewControllers.enumerated() {
            let slicePositionX:CGFloat = self.recordButtonView.getSlicePosition(index: i)
            let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
            
            bezierViewController.points = self.generatePoints(index: i, slicePositionX: slicePositionX,
                                                              slicePositionY: slicePositionY)
            
            bezierViewController.pointsChanged()
        }
    }
    
    func reset() {
        self.scrubberView.removeAllImages()
    }
    
    func loadThumbnails(images: [UIImage]) {
        for image in images {
            self.scrubberView.addImage(image: image)
        }
    }
    
    func load(duration: CMTime, audioURL: URL) {
        self.scrubberView.length = Int(CMTimeGetSeconds(duration))*100
        self.recordButtonView.length = Int(CMTimeGetSeconds(duration))*100
        
        DispatchQueue.main.sync {
            self.scrubberView.resetTimes()
            self.scrubberView.waveformView.audioURL = audioURL
        }
    }
    
    func updateLines(index: Int, distance: Int) {
        let slicePositionX:CGFloat = self.scrubberView.getSlicePosition(index: index)
        let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
        
        self.bezierViewControllers[index].points = self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY)
        
        self.bezierViewControllers[index].pointsChanged()
        
        self.recordButtonView.updateFlipper(index: index, distance: CGFloat(distance))
    }
    
    func updateLines2(index: Int, distance: Int) {
        let slicePositionX:CGFloat = self.recordButtonView.getSlicePosition(index: index)
        let slicePositionY:CGFloat = self.scrubberView.frame.origin.y
        
        self.bezierViewControllers[index].points = self.generatePoints(index: index, slicePositionX: slicePositionX, slicePositionY: slicePositionY)
        
        self.bezierViewControllers[index].pointsChanged()
        
        self.scrubberView.updateFlipper(index: index, distance: CGFloat(distance))
    }
    
    func generatePoints(index: Int, slicePositionX: CGFloat, slicePositionY: CGFloat) -> [NSValue] {
        var points:[NSValue] = []
        let buttonHeight = self.playButtonsView.button0.frame.height
        
        // original slice position
        points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                               y: slicePositionY)))
        
        // just above the slice position
        points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                               y: slicePositionY - 10)))
        
        // just below the play buttons
        points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                               y: self.playButtonsView.buttonCenter(atIndex: index).y + buttonHeight/2 + 10)))
        
        // the middle of the play button position
        points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                               y: self.playButtonsView.buttonCenter(atIndex: index).y)))
        
        // just above the play button position
        
        if (Device.type() == .iPad) {
            points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                                   y: self.playButtonsView.buttonCenter(atIndex: index).y - 75)))
        } else {
            points.append(NSValue(cgPoint: CGPoint(x: self.playButtonsView.buttonCenter(atIndex: index).x,
                                                   y: self.playButtonsView.buttonCenter(atIndex: index).y - 50)))
        }
        
        var offset = CGFloat(index*10)
        if (index == 0) {
            offset = CGFloat((index+1) * 10)
        } else {
            offset = CGFloat(index*10)
        }
        
        if (Device.type() == .iPad) {
            let origin:CGPoint = self.recordButtonView.slices[index].frame.origin
            let newOrigin:CGPoint = CGPoint(x: origin.x + 10, y: origin.y - 15)
            let point:CGPoint = self.view.convert(newOrigin, from: self.recordButtonView.slices[index])
            
            points.append(NSValue(cgPoint: point))
        } else {
            points.append(NSValue(cgPoint: CGPoint(x: slicePositionX + 10,
                                                   y: slicePositionY - 100 + offset)))
        }
        
        
        
        return points
    }
    
    
    func drawLineFromPointToPoint(startX: Int, toEndingX endX: Int, startingY startY: Int, toEndingY endY: Int, ofColor lineColor: UIColor, widthOfLine lineWidth: CGFloat, inView view: UIView) {
        
        if (self.path == nil ) {
            self.path = UIBezierPath()
        }
        
        self.path.addLine(to: CGPoint(x: endX, y: endY))
        self.path.move(to: CGPoint(x: startX, y: startY))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
        
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        view.layer.addSublayer(shapeLayer)
    }
    
    func assetTimeChanged(player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
        self.scrubberView.waveformView.progressSamples = Int(CGFloat(fraction) * CGFloat(self.scrubberView.waveformView.totalSamples))
    }
}

extension MainControlViewController : ScrubberViewDelegate {
    func draggingHasBegun(index: Int) {
        self.delegate.draggingHasBegun(index: index)
    }
    
    func sliceWasMovedTo(index: Int, distance: Int) {
        self.delegate.sliceWasMoved(index:index, distance: distance)
        self.updateLines(index: index, distance: distance)
    }
    
    func draggingHasEnded(index: Int) {
        self.delegate.draggingHasEnded(index: index)
    }
}

extension MainControlViewController : RecordButtonsViewDelegate {
    func recordButtonDraggingHasBegun(index: Int) {
        self.delegate.draggingHasBegun(index: index)
    }
    
    func recordButtonSliceWasMovedTo(index: Int, distance: Int) {
        self.delegate.sliceWasMoved(index: index, distance: distance)
        self.updateLines2(index: index, distance: distance)
    }
    
    func recordButtonDraggingHasEnded(index: Int) {
        self.delegate.draggingHasEnded(index: index)
    }
}

extension MainControlViewController : PlayButtonViewDelegate {
    
    func playButtonWasTapped(index: Int) {
        self.scrubberView.blowUpSliceAt(index: index)
        
        let distance = self.scrubberView.getSlicePosition(index: index)
        
        self.scrubberView.waveformView.progressSamples = Int((distance + 10)/self.scrubberView.frame.width * CGFloat(self.scrubberView.waveformView.totalSamples))
        
        _ =  self.scrubberView.frame.origin.y + self.scrubberView.frame.size.height/2
        
        self.dazzleController.touch(atPosition: CGPoint(x: self.recordButtonView.getSlicePosition(index: index) + 10, y: self.recordButtonView.frame.origin.y + CGFloat(index*10)))
        
        self.delegate.playerButtonWasTapped(index: index)
    }
}
