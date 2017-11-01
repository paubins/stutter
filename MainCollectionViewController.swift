//
//  ThumbnailCollectionViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 10/30/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import Cartography
import Player
import Device
import FDWaveformView

enum SliderSections : Int {
    case scrubberPreview = 0
    case slices
    case buttons
    case waveform
    case thumbnails
    
    static func count() -> Int {
        return SliderSections.thumbnails.rawValue + 1
    }
}

protocol MainCollectionViewControllerDelegate {
    func playButtonWasTapped(index: Int)
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat)
}

class MainCollectionViewController : UICollectionViewController {
    
    var thumbnails:[UIImage] = []
    var audioURL:URL! {
        didSet {
            self.collectionView?.reloadSections(IndexSet(integer: SliderSections.waveform.rawValue))
        }
    }
    
    var waveformColor:UIColor!
    var progressSamples:CGFloat = 0
    var longPressGesture: UILongPressGestureRecognizer!
    
    var delegate:MainCollectionViewControllerDelegate!

    var path:UIBezierPath!
    
    var bezierViewControllers:[BezierViewController] = []
    let dazzleController:DazTouchController = DazTouchController()
    
    let bezierView:UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        return view
    }()

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
         self.view.backgroundColor = .clear
        
        self.collectionView?.register(ScrubberPreviewViewControllerCollectionViewCell.self, forCellWithReuseIdentifier: "ScrubberPreviewViewControllerCollectionViewCell")
        self.collectionView?.register(PlayButtonCollectionViewControllerCell.self, forCellWithReuseIdentifier: "PlayButtonCollectionViewControllerCell")
        self.collectionView?.register(ScrubberCollectionViewCell.self, forCellWithReuseIdentifier: "ScrubberCollectionViewCell")
        self.collectionView?.register(WaveformCollectionViewCell.self, forCellWithReuseIdentifier: "WaveformCollectionViewCell")
        self.collectionView?.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "ThumbnailCollectionViewCell")
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(self.dazzleController)
        
        self.view.insertSubview(self.dazzleController.view, belowSubview: self.collectionView!)
        self.view.insertSubview(self.bezierView, belowSubview: self.collectionView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        constrain(self.dazzleController.view) { (view) in
            view.top == view.superview!.top
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
        
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureMethod)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeAllImages() {
        self.thumbnails = []
        self.collectionView?.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return 0
        }
        
        var count:Int = 0
        
        switch(section) {
        case .scrubberPreview:
            count = 1
            break
        case .buttons:
            count = 5
            break
        case .slices:
            count = 1
            break
        case .waveform:
            count = self.audioURL != nil ? 1 : 0
            break
        case .thumbnails:
            count = self.thumbnails.count
            break
        default:
            break
        }
        
        return count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SliderSections.count()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = SliderSections(rawValue: indexPath.section) else {
            assertionFailure()
            return UICollectionViewCell()
        }
        
        switch(section) {
        case .scrubberPreview:
            let cell:ScrubberPreviewViewControllerCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrubberPreviewViewControllerCollectionViewCell", for: indexPath) as! ScrubberPreviewViewControllerCollectionViewCell
            return cell
        case .buttons:
            let cell:PlayButtonCollectionViewControllerCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayButtonCollectionViewControllerCell", for: indexPath) as! PlayButtonCollectionViewControllerCell
            cell.delegate = self
            cell.color = Constant.COLORS[indexPath.row]
            return cell
        case .slices:
            let cell:ScrubberCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrubberCollectionViewCell", for: indexPath) as! ScrubberCollectionViewCell
            cell.delegate = self
            return cell
        case .waveform:
            let cell:WaveformCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "WaveformCollectionViewCell", for: indexPath) as! WaveformCollectionViewCell
            cell.updateAudioURL(audioURL: self.audioURL)
            return cell
        case .thumbnails:
            let cell:ThumbnailCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCollectionViewCell", for: indexPath) as! ThumbnailCollectionViewCell
            cell.thumbnailImageView.image = self.thumbnails[indexPath.row]
            return cell
        default:
            break
        }
        
//        cell.contentView.addSubview(self.thumbnails[indexPath.row])
        
        return UICollectionViewCell()
    }

    func loadThumbnails(images: [UIImage]) {
        self.thumbnails = images
        self.collectionView?.reloadData()
    }
    
    func orientationChange(notification: Notification) {
        //        for (i, bezierViewController) in  self.bezierViewControllers.enumerated() {
        //            var slicePositionX:CGFloat = self.recordButtonView.getSlicePosition(index: i)
        //            if (UIScreen.main.bounds.size.width < slicePositionX) {
        //                slicePositionX = slicePositionX/self.previousScreenWidth * UIScreen.main.bounds.width
        //                self.recordButtonView.updateFlipper(index: i, distance: CGFloat(slicePositionX))
        //            }
        //
        //            let slicePositionY:CGFloat = self.scrubberViewCollectionViewController.view.frame.origin.y
        //
        //            bezierViewController.points = self.generatePoints(index: i, slicePositionX: slicePositionX,
        //                                                              slicePositionY: slicePositionY)
        //
        //            bezierViewController.pointsChanged()
        //
        //            self.mainCollectionViewController.updateFlipper(index: i, distance: CGFloat(slicePositionX))
        //        }
        //
        //        self.previousScreenWidth = UIScreen.main.bounds.size.width
    }
    
    func reset() {
        self.removeAllImages()
    }

    func load(duration: CMTime, audioURL: URL) {
        DispatchQueue.main.sync {
            //            self.thumbnailViewController.resetTimes()
            self.audioURL = audioURL
        }
    }
    
    func load(asset: AVAsset) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.scrubberPreview.rawValue)
        let cell:ScrubberPreviewViewControllerCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberPreviewViewControllerCollectionViewCell
        
        cell.load(asset: asset)
    }
    
    func assetTimeChanged(player: Player) {
        let fraction:Double = Double(player.currentTime) / Double(player.maximumDuration)
        
        self.updateSamples(distance: CGFloat(fraction))
        //        self.mainCollectionViewController.waveformView.progressSamples = Int(CGFloat(fraction) * CGFloat(self.scrubberView.waveformView.totalSamples))
    }
    
    func blowUpSliceAt(index: Int) {
//        self.slices[index].shake()
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .allowUserInteraction, animations: {
//            self.slices[index].frame.origin.x += 5
//            self.slices[index].frame.origin.x -= 5
//        }, completion: nil)
    }
    
    
    func getSlicePosition(index:Int) -> CGFloat {
//        return slices[index].superview!.frame.origin.x
        return 0.0
    }
    
    func updateFlipper(index:Int, distance: CGFloat) {
//        let layoutConstraint:NSLayoutConstraint = self.flippers[index]
//        layoutConstraint.constant = distance
    }
    
    func resetTimes() {
//        for slice:UIView in self.slices {
//            let currentTime = Int(floor(Float(self.length) * Float(((slice.superview?.frame.origin.x)!/(UIScreen.main.bounds.width - 10.0)))))
//            self.delegate?.sliceWasMovedTo(index: (slice.tag), distance: Int((slice.superview?.frame.origin.x)!))
//        }
    }
    
    func playButtonWasTapped(index: Int) {
//        self.progressColor = Constant.COLORS[index]
//        self.mainCollectionViewController
//
//        self.mainCollectionViewController.blowUpSliceAt(index: index)
//
//        let distance = self.mainCollectionViewController.getSlicePosition(index: index)
//
//        self.mainCollectionViewController.waveformView.progressSamples = Int((distance + 10)/self.thumbnailViewController.view.frame.width * CGFloat(self.waveformView.totalSamples))
//
//        _ =  self.mainCollectionViewController.view.frame.origin.y + self.thumbnailViewController.view.frame.size.height/2
        self.updateColor(index: index)
        self.blowUpSliceAt(index: index)
        
        let distance = self.getSlicePosition(index: index)
        
        self.updateSamples(distance: distance)
        
        //        self.dazzleController.touch(atPosition: CGPoint(x: self.recordButtonView.getSlicePosition(index: index) + 10, y: self.recordButtonView.frame.origin.y + CGFloat(index*10)))
        //
//        self.delegate.playerButtonWasTapped(index: index)
    }
    
    
    func updateColor(index: Int) {
        self.waveformColor = Constant.COLORS[index]
    }
    
    func updateSamples(distance: CGFloat) {
        let cell:WaveformCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.waveform.rawValue)) as! WaveformCollectionViewCell
        
        cell.waveformView.progressSamples = Int(CGFloat(cell.waveformView.totalSamples) * distance)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
    }
    
    var currentTimer:Timer!
    
    func panGestureMethod(gesture:UIPanGestureRecognizer) {
        // Get the gesture's point location within its view
        // (This answer assumes the gesture and the buttons are
        // within the same view, ex. the gesture is attached to
        // the view controller's superview and the buttons are within
        // that same superview.)
        let pointInView = gesture.location(in: gesture.view)

        // For each button, if the gesture is within the button and
        // the button hasn't yet been added to the array, add it to the
        // array. (This example uses 4 buttons instead of 9 for simplicity's
        // sake
        
        let indexPath:IndexPath? = self.collectionView?.indexPathForItem(at: pointInView)
        
        if (indexPath == nil) {
            print("not a button")
            return
        }
        
        guard let section = SliderSections(rawValue: indexPath!.section) else {
            assertionFailure()
            return
        }
        
        switch(section) {
        case .buttons:
            var fireButton:PlayButtonCollectionViewControllerCell! = self.collectionView?.cellForItem(at: indexPath!) as! PlayButtonCollectionViewControllerCell
            
            if fireButton != nil {
                if (self.currentTimer == nil) {
                    fireButton.isHighlighted = true
                    self.currentTimer = Timer.after(0.25.seconds) {
                        fireButton.button0.sendActions(for: UIControlEvents.touchUpInside)
                        fireButton.isHighlighted = false
                        
                        self.currentTimer.invalidate()
                        self.currentTimer = nil
                    }
                }
            }
        default:
            print("not a button")
        }
    }
}

extension MainCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = SliderSections(rawValue: indexPath.section) else {
            assertionFailure()
            return CGSize()
        }
        
        let kWhateverHeightYouWant = 50
        
        switch(section) {
        case .scrubberPreview:
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(kWhateverHeightYouWant))
        case .buttons:
            return CGSize(width: collectionView.bounds.size.width/5, height: CGFloat(kWhateverHeightYouWant))
        case .slices:
            return CGSize(width: collectionView.bounds.size.width, height: 200)
        case .waveform:
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(kWhateverHeightYouWant))
        case .thumbnails:
            return CGSize(width: collectionView.bounds.size.width/CGFloat(self.thumbnails.count), height: CGFloat(kWhateverHeightYouWant))
        default:
            break
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return UIEdgeInsets()
        }
        
        switch(section) {
        case .scrubberPreview:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .buttons:
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        case .slices:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .waveform:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .thumbnails:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            break
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension MainCollectionViewController : PlayButtonCollectionViewControllerCellDelegate {
    func playButtonTapped(cell: PlayButtonCollectionViewControllerCell) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.waveform.rawValue)
        let waveformCell:WaveformCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! WaveformCollectionViewCell
        
        let index:Int = (self.collectionView?.indexPath(for: cell)?.row)!
        
        waveformCell.waveformView.progressColor = Constant.COLORS[index]
        self.delegate.playButtonWasTapped(index: index)
    }
}

extension MainCollectionViewController : ScrubberCollectionViewCellDelegate {
    
    func scrubbingHasBegun() {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.scrubberPreview.rawValue)
        let cell:ScrubberPreviewViewControllerCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberPreviewViewControllerCollectionViewCell
        cell.showScrubberPreview()
    }
    
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.scrubberPreview.rawValue)
        let scrubberPreviewCell:ScrubberPreviewViewControllerCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberPreviewViewControllerCollectionViewCell
        
//        cell.seek(to: time, distance: distance)
        
        self.delegate.scrubbed(index: index, percentageX: percentageX, percentageY: percentageY)
    }
    
    func scrubbingHasEnded() {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.scrubberPreview.rawValue)
        let cell:ScrubberPreviewViewControllerCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberPreviewViewControllerCollectionViewCell
        cell.hideScrubberPreview()
    }
}


