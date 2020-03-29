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
    case slices = 0
    case buttons
    case thumbnails
    case waveform
    
    static func count() -> Int {
        return SliderSections.waveform.rawValue + 1
    }
}

protocol MainCollectionViewControllerDelegate {
    func playButtonWasTapped(index: Int, timelinePercentageX: CGFloat, percentageX: CGFloat, percentageY: CGFloat)
    func scrubbingHasBegun(at point:CGPoint)
    func scrubbingHasMoved(index: Int, percentageX: CGFloat, percentageY: CGFloat, to point:CGPoint)
    func scrubbingHasEnded(at point:CGPoint)
    func tapped()
    func timelineScrubbingHasBegun(point: CGPoint)
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint)
    func timelineScrubbingHasEnded(point: CGPoint)
}

class MainCollectionViewController : UICollectionViewController {
    
    var thumbnails:[UIImage] = []
    var audioURL:URL! {
        didSet {
            self.collectionView?.reloadSections(IndexSet(integer: SliderSections.waveform.rawValue))
        }
    }
    
    var asset:AVAsset!
    var size:CGSize!
    var currentTimer:Timer!

    var delegate:MainCollectionViewControllerDelegate!
    let dazzleController:DazTouchController = DazTouchController()

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.view.backgroundColor = .clear

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
        
        constrain(self.dazzleController.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        self.collectionView?.delaysContentTouches = false
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureMethod)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let asset = self.asset else {
            return
        }
        
        self.loadThumbnails(images: [])
        let size:CGSize = asset.getSize()
        let newSize:CGSize = AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: 100, height: 50)).size
        
        asset.getThumbnails(size: newSize, completionHandler: { (images) in
            DispatchQueue.main.sync {
                self.loadThumbnails(images: images)
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        })
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return 0
        }
        
        var count:Int = 0
        
        switch(section) {
        case .buttons:
            count = 5
            break
        case .slices:
            count = 1
            break
        case .waveform:
            count = 1
            break
        case .thumbnails:
            count = self.thumbnails.count == 0 ? 1 : self.thumbnails.count
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
            if (self.audioURL != nil) {
                cell.updateAudioURL(audioURL: self.audioURL)
            }
            return cell
        case .thumbnails:
            let cell:ThumbnailCollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCollectionViewCell", for: indexPath) as! ThumbnailCollectionViewCell
            if (0 < self.thumbnails.count) {
                cell.thumbnailImageView.image = self.thumbnails[indexPath.row]
            }
            return cell
        default:
            break
        }
        
//        cell.contentView.addSubview(self.thumbnails[indexPath.row])
        
        return UICollectionViewCell()
    }

    func loadThumbnails(images: [UIImage]) {
        self.thumbnails = images
        self.collectionView?.reloadSections(IndexSet(integer: SliderSections.thumbnails.rawValue))
    }
    
    func orientationChange(notification: Notification) {
        
    }
    
    func load(duration: CMTime, audioURL: URL, size: CGSize) {
        DispatchQueue.main.sync {
            self.audioURL = audioURL
            self.size = size
        }
    }

    func assetTimeChanged(player: Player) {
        self.updateSamples(distance: CGFloat(Double(player.currentTime) / Double(player.maximumDuration)))
    }
    
    func updateSamples(distance: CGFloat) {
        DispatchQueue.main.async {
            if (self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.waveform.rawValue)) != nil) {
                let cell:WaveformCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.waveform.rawValue)) as! WaveformCollectionViewCell
                
                cell.waveformView.progressSamples = Int(CGFloat(cell.waveformView.totalSamples) * distance)
            }
        }
    }
    
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
    
    func getTimelinePercentageX(index: Int) -> CGFloat {
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.slices.rawValue)) as! ScrubberCollectionViewCell
        
        return cell.getTimelinePercentageX(index: index)
    }
    
    func getCurrentPercentageX(index: Int) -> CGFloat {
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.slices.rawValue)) as! ScrubberCollectionViewCell
        
        return cell.getPercentageX(index: index)
    }
    
    func getSpeedPercentageX(index: Int) -> CGFloat {
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.slices.rawValue)) as! ScrubberCollectionViewCell
        
        return cell.getSpeedPercentageX(index: index)
    }
    
    func getCurrentPercentageY(index: Int) -> CGFloat {
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: SliderSections.slices.rawValue)) as! ScrubberCollectionViewCell
        
        return cell.getPercentageY(index: index)
    }
}

extension MainCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
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
            return CGSize(width: collectionView.bounds.size.width/6, height: CGFloat(kWhateverHeightYouWant))
        case .slices:
            return CGSize(width: collectionView.bounds.size.width, height: Constant.mainControlHeight)
        case .waveform:
            if UIScreen.isPhoneX {
                return CGSize(width: (collectionView.bounds.size.width - 40), height: CGFloat(kWhateverHeightYouWant+10))
            }
            return CGSize(width: (collectionView.bounds.size.width - 40), height: CGFloat(kWhateverHeightYouWant))
        case .thumbnails:
            if UIScreen.isPhoneX {
                return thumbnails.count == 0 ? CGSize(width: (collectionView.bounds.size.width - 40), height: CGFloat(kWhateverHeightYouWant+10)) : CGSize(width: (collectionView.bounds.size.width - 40)/CGFloat(self.thumbnails.count), height: CGFloat(kWhateverHeightYouWant+10))
            }
            
            return thumbnails.count == 0 ? CGSize(width: (collectionView.bounds.size.width - 40), height: CGFloat(kWhateverHeightYouWant)) : CGSize(width: (collectionView.bounds.size.width - 40)/CGFloat(self.thumbnails.count), height: CGFloat(kWhateverHeightYouWant))
        default:
            break
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return 0
        }
        
        switch(section) {
        case .buttons:
            return 10
        case .slices:
            return 0
        case .waveform:
            return 0
        case .thumbnails:
            return  0
        default:
            break
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return 0
        }
        
        switch(section) {
        case .buttons:
            return 0
        case .slices:
            return 0
        case .waveform:
            return 0
        case .thumbnails:
            return  0
        default:
            break
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = SliderSections(rawValue: section) else {
            assertionFailure()
            return UIEdgeInsets()
        }
        
        switch(section) {
        case .buttons:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        case .slices:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .waveform:
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        case .thumbnails:
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
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
        
        let scrubberIndexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        
        let scrubberCell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: scrubberIndexPath) as! ScrubberCollectionViewCell
        
        self.dazzleController.touch(atPosition: scrubberCell.getPoint(for: index))
        
        self.delegate.playButtonWasTapped(index: index,
                                          timelinePercentageX: self.getTimelinePercentageX(index: index),
                                          percentageX: self.getSpeedPercentageX(index: index),
                                          percentageY: self.getCurrentPercentageY(index: index))
    }
}

extension MainCollectionViewController : ScrubberCollectionViewCellDelegate {
    func scrubbingHasBegun(at: CGPoint) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberCollectionViewCell
        
        let newPoint:CGPoint = cell.convert(at, to: self.view.superview)
        
        self.delegate.scrubbingHasBegun(at: newPoint)
    }
    
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat, to: CGPoint) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberCollectionViewCell
        
        let newPoint:CGPoint = cell.convert(to, to: self.view.superview)
        
        self.delegate.scrubbingHasMoved(index: index, percentageX: percentageX, percentageY: percentageY, to: newPoint)
    }
    
    func scrubbingHasEnded(at: CGPoint) {
        self.delegate.scrubbingHasEnded(at: at)
    }
    
    func tapped() {
        self.delegate.tapped()
    }
    
    func timelineScrubbingHasBegun(point: CGPoint) {
        self.delegate.timelineScrubbingHasBegun(point: point)
    }
    
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint) {
        self.delegate.timelinePercentageOfWidth(index: index, percentageX: percentageX, percentageY: percentageY, point: point)
    }
    
    func timelineScrubbingHasEnded(point: CGPoint) {
        self.delegate.timelineScrubbingHasEnded(point: point)
    }
}


