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
import Shift

enum SliderSections : Int {
    case slices = 0
    case buttons
    case thumbnails
    case waveform
    
    static func count() -> Int {
        return SliderSections.waveform.rawValue + 1
    }
}

class MainCollectionViewController : UICollectionViewController {
    var thumbnails:[UIImage] = []
    var audioURL:URL! {
        didSet {
            self.collectionView?.reloadSections(IndexSet(integer: SliderSections.waveform.rawValue))
        }
    }
    
    var size:CGSize!
    var currentTimer:Timer!

    let dazzleController:DazTouchController = DazTouchController()
    
    var backgroundShiftView:ShiftView = {
        let v = ShiftView()
        
        // set colors
        v.setColors(Constant.DARKER_COLORS)
        
        return v
    }()
    
    var stutterState:StutterState = .prearmed
    
    lazy var backBarButtonItem:UIBarButtonItem = {
        let button:UIButton = UIButton.backButton()
        button.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var nextBarButtonItem:UIBarButtonItem = {
        let button:UIButton = UIButton.nextButton()
        button.addTarget(self, action: #selector(self.exportButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var previewContainerView:UIView = {
        let previewContainerView:UIView = UIView(frame: .zero)
        previewContainerView.clipsToBounds = true
        previewContainerView.layer.cornerRadius = 5
        previewContainerView.layer.borderColor = Constant.COLORS[0].cgColor
        previewContainerView.layer.borderWidth = 2
        
        previewContainerView.addSubview(self.scrubberPreviewViewController.view)
        
        constrain(self.scrubberPreviewViewController.view) { (view) in
            view.height == 100
            view.width == 100
            
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY
        }
        
        return previewContainerView
    }()
    
    lazy var waveformCell:WaveformCollectionViewCell = {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.waveform.rawValue)
        let waveformCell:WaveformCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! WaveformCollectionViewCell
        return waveformCell
    }()
    
    lazy var scrubberCell:ScrubberCollectionViewCell = {
        let scrubberIndexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        let scrubberCell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: scrubberIndexPath) as! ScrubberCollectionViewCell
        return scrubberCell
    }()

    lazy var scrubberPreviewViewController:Player = {
        let scrubberPreviewViewController:Player = Player()
        scrubberPreviewViewController.view.backgroundColor = .clear
        scrubberPreviewViewController.playbackResumesWhenEnteringForeground = false
        scrubberPreviewViewController.view.isHidden = false
        return scrubberPreviewViewController
    }()
    
    lazy var playerViewController:Player = {
        let player:Player = Player()
        
        player.playbackDelegate = self
        player.view.frame = self.view.bounds
        player.fillMode = AVLayerVideoGravityResizeAspect
        player.playbackLoops = false
        player.view.backgroundColor = .clear
        player.playbackResumesWhenEnteringForeground = false
        player.playbackFreezesAtEnd = true
        
        player.view.isUserInteractionEnabled = true
        
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerViewtapped))
        player.view.addGestureRecognizer(tapGestureRecognizer)
        
        return player
    }()
    
    init(url: URL) {
        super.init(collectionViewLayout: MainCollectionViewLayout())

        self.view.backgroundColor = .clear
        
        self.collectionView?.register(PlayButtonCollectionViewControllerCell.self, forCellWithReuseIdentifier: "PlayButtonCollectionViewControllerCell")
        self.collectionView?.register(ScrubberCollectionViewCell.self, forCellWithReuseIdentifier: "ScrubberCollectionViewCell")
        self.collectionView?.register(WaveformCollectionViewCell.self, forCellWithReuseIdentifier: "WaveformCollectionViewCell")
        self.collectionView?.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "ThumbnailCollectionViewCell")
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        EditController.shared.load(url: url)
        
        EditController.shared.asset.getThumbnails(size: AVMakeRect(aspectRatio: EditController.shared.asset.getSize(), insideRect: CGRect(x: 0, y: 0, width: 100, height: 50)).size, completionHandler: { (images) in
            DispatchQueue.main.async {
                self.loadThumbnails(images: images)
            }
        })
        
        self.stutterState = .prearmed
        self.previewContainerView.isHidden = true
        self.audioURL = url
        
        self.playerViewController.url = url
        self.scrubberPreviewViewController.url = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.addChildViewController(self.playerViewController)
        self.addChildViewController(self.dazzleController)

        self.view.addSubview(self.previewContainerView)
        self.view.insertSubview(self.dazzleController.view, belowSubview: self.collectionView!)
        self.view.insertSubview(self.playerViewController.view, belowSubview: self.dazzleController.view)
        self.view.insertSubview(self.backgroundShiftView, belowSubview: self.playerViewController.view)
        
        constrain(self.dazzleController.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.backgroundShiftView) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        constrain(self.playerViewController.view) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        self.backgroundShiftView.animationDuration(20.0)
        
        constrain(self.collectionView!) { (view) in
            view.height == Constant.mainControlHeight
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        self.collectionView?.delaysContentTouches = false
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureMethod)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.backgroundShiftView.startTimedAnimation()
        self.previewContainerView.isHidden = true
        
        self.stutterState = .prearmed
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let asset = EditController.shared.asset else {
            return
        }
        
        self.loadThumbnails(images: [])
        let size:CGSize = asset.getSize()
        let newSize:CGSize = AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: 100, height: 50)).size
        
        asset.getThumbnails(size: newSize, completionHandler: { (images) in
            DispatchQueue.main.async {
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
    
    func playerViewtapped(gestureRecognizer: UITapGestureRecognizer) {
//        self.timerLabel.pause()
        
        if (gestureRecognizer.location(in: self.view).x < UIScreen.main.bounds.width/4) {
            self.playerViewController.playFromBeginning()
        } else if self.playerViewController.playbackState == .playing {
            self.playerViewController.stop()
        } else {
            self.playerViewController.playFromCurrentTime()
        }
    }
    
    
    func setNavBarToTheView() {
        self.nextBarButtonItem.isEnabled = true
        self.nextBarButtonItem.tintColor = nil
    }
    
    func exportButtonTapped() {
        guard self.stutterState == .recording || self.stutterState == .paused else {
            return
        }
        
//        self.timerLabel.pause()
        EditController.shared.closeEdit()
        self.playerViewController.stop()
        self.stutterState = .exporting
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController?.pushViewController(PreviewViewController(), animated: true)
    }
    
    func back(barButtonItem: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
                return CGSize(width: (collectionView.bounds.size.width), height: CGFloat(kWhateverHeightYouWant+10))
            }
            return CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat(kWhateverHeightYouWant))
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
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        if (self.navigationItem.rightBarButtonItem == nil) {
            self.navigationItem.rightBarButtonItem = self.nextBarButtonItem
        }
        
        let index:Int = (self.collectionView?.indexPath(for: cell)?.row)!
        
        self.waveformCell.waveformView.progressColor = Constant.COLORS[index]
        
        self.dazzleController.touch(atPosition: (self.collectionView?.convert(self.scrubberCell.getPoint(for: index), to: self.view))!, color: Constant.COLORS[index])
        
        var time:CMTime = kCMTimeZero

        let timelinePercentageX = self.getTimelinePercentageX(index: index)
        let percentageX = self.getSpeedPercentageX(index: index)
        let percentageY = self.getCurrentPercentageY(index: index)
        
        switch self.stutterState {
        case .prearmed:
            self.setNavBarToTheView()
            
            self.stutterState = .recording
            time = EditController.shared.storeEdit(percentageOfTime: timelinePercentageX,
                                            percentageZoom: percentageY,
                                            percentageSpeed: percentageX)
//            self.timerLabel.start()
            
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            
            break
        case .recording:
//            self.timerLabel.start()
            
            time = EditController.shared.storeEdit(percentageOfTime: timelinePercentageX,
                                            percentageZoom: percentageY,
                                            percentageSpeed: percentageX)
            
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            
            break
        case .paused:
            self.stutterState = .recording
//            self.timerLabel.start()
            
            time = EditController.shared.storeEdit(percentageOfTime: timelinePercentageX,
                                            percentageZoom: percentageY,
                                            percentageSpeed: percentageX)
            self.playerViewController.view.layer.transform = CATransform3DMakeScale(1 + percentageY, 1 + percentageY, 1)
            
            break
        default:
            break
        }
        
        
        self.playerViewController.seekToTime(to: time, toleranceBefore: CMTimeMake(1, 600), toleranceAfter: CMTimeMake(1, 600))
        self.playerViewController.playFromCurrentTime()
        self.playerViewController.setRate(rate: Float(1 + 1 * percentageX))
        

    }
}

extension MainCollectionViewController : ScrubberCollectionViewCellDelegate {
    func scrubbingHasBegun(at: CGPoint) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberCollectionViewCell
        
        let newPoint:CGPoint = cell.convert(at, to: self.view.superview)
        
        self.previewContainerView.frame.origin = newPoint
        self.previewContainerView.isHidden = false
    }
    
    func scrubbed(index: Int, percentageX: CGFloat, percentageY: CGFloat, to: CGPoint) {
        let indexPath:IndexPath = IndexPath(row: 0, section: SliderSections.slices.rawValue)
        let cell:ScrubberCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! ScrubberCollectionViewCell
        
        let newPoint:CGPoint = cell.convert(to, to: self.view.superview)
        
        self.previewContainerView.frame.origin = to
        self.scrubberPreviewViewController.view.layer.transform = CATransform3DMakeScale(percentageY+1, percentageY+1, 1)
    }
    
    func scrubbingHasEnded(at: CGPoint) {
        self.previewContainerView.frame.origin = at
        self.previewContainerView.isHidden = true
    }
    
    func tapped() {
        switch self.playerViewController.playbackState {
        case .playing:
//            self.timerLabel.pause()
            self.playerViewController.pause()
            break
        case .paused:
            self.playerViewController.playFromCurrentTime()
            break
        case .stopped:
            self.playerViewController.playFromBeginning()
            break
        default:
            break
        }
    }
    
    func timelineScrubbingHasBegun(point: CGPoint) {
        self.previewContainerView.frame.origin = point
        self.previewContainerView.isHidden = false
    }
    
    func timelinePercentageOfWidth(index: Int, percentageX: CGFloat, percentageY: CGFloat, point: CGPoint) {
        print("percentage")
        self.previewContainerView.frame.origin = point
        self.scrubberPreviewViewController.seekToTime(to: CMTimeMakeWithSeconds(Float64(CGFloat(CMTimeGetSeconds(EditController.shared.currentAssetDuration)) * percentageX), 60), toleranceBefore: CMTimeMake(1, 60), toleranceAfter: CMTimeMake(1, 60))
    }
    
    func timelineScrubbingHasEnded(point: CGPoint) {
        print("timeline ended")
        self.previewContainerView.isHidden = true
        self.previewContainerView.frame.origin = point
    }
}

extension MainCollectionViewController: PlayerPlaybackDelegate {
    
    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    public func playerPlaybackDidEnd(_ player: Player) {
//        self.timerLabel.pause()
    }
    
    public func playerCurrentTimeDidChange(_ player: Player) {
        self.assetTimeChanged(player: player)
    }
    
    public func playerPlaybackWillLoop(_ player: Player) {
        //        if (self.stutterState == .recording) {
        //            self.editController.closeEdit()
        //        }
    }
}

extension MainCollectionViewController : PlayerDelegate {
    func playerReady(_ player: Player) {
        print("ready")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        switch player.playbackState {
        case .playing:
            switch self.stutterState {
            case .recording:
                let _:CMTime = EditController.shared.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0, percentageSpeed: 0)
//                self.timerLabel.start()
                self.stutterState = .recording
            default:
                print("default")
            }
            break
            
        case .paused:
            switch self.stutterState {
            case .recording:
                let _:CMTime = EditController.shared.storeEdit(percentageOfTime: CGFloat(player.currentTime/player.maximumDuration), percentageZoom: 0, percentageSpeed: 0)
                
//                self.timerLabel.pause()
                self.stutterState = .paused
            default:
                print("default")
            }
            break
        case .stopped:
//            self.timerLabel.pause()
            break
        default:
            print("unknown")
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    //this is the time in seconds that the video has buffered to.
    //If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
}
