//
//  TwitterProfileViewController.swift
//  TwitterProfileViewController
//
//  Created by Roy Tang on 30/9/2016.
//  Copyright © 2016 NA. All rights reserved.
//

import UIKit
import SnapKit

open class TwitterProfileViewController: UIViewController {
    
    // Global tint
    open static var globalTint: UIColor = UIColor(red: 42.0/255.0, green: 163.0/255.0, blue: 239.0/255.0, alpha: 1)

    // Constants
    open let stickyheaderContainerViewHeight: CGFloat = 0
    
    open let bouncingThreshold: CGFloat = 100
    
    open let scrollToScaleDownProfileIconDistance: CGFloat = 0
    
    open var profileHeaderViewHeight: CGFloat = 228
    
    open let segmentedControlContainerHeight: CGFloat = 26
    
    open var tabOptionsView: UIView?
    
    open var coverImage: UIImage? {
        didSet {
            self.headerCoverView?.image = coverImage
        }
    }
    
    // Properties
    
    var currentIndex: Int = 0 {
        didSet {
            self.updateTableViewContent()
        }
    }
    
    var scrollViews: [UIScrollView] = []
    
    var currentScrollView: UIScrollView {
        return scrollViews[currentIndex]
    }
    
    
    var mainScrollView: UIScrollView!
    
    var headerCoverView: RMUserCoverImageView!
    
    var profileHeaderView: TwitterProfileHeaderView!
    
    var stickyHeaderContainerView: UIView!
    
    var segmentedControlContainer: UIView!
    
    var debugTextView: UILabel!
    
    var shouldUpdateScrollViewContentFrame = false
    
    deinit {
        self.scrollViews.forEach { (scrollView) in
            scrollView.removeFromSuperview()
        }
        self.scrollViews.removeAll()
        
        print("[TwitterProfileViewController] memeory leak check passed")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareForLayout()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.prepareViews()
        
        shouldUpdateScrollViewContentFrame = true
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        print(profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size))
        self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size).height
        if self.shouldUpdateScrollViewContentFrame {
            // configure layout frames
            self.stickyHeaderContainerView.frame = self.computeStickyHeaderContainerViewFrame()
            self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            self.segmentedControlContainer.frame = self.computeSegmentedControlContainerFrame()
            self.scrollViews.forEach({ (scrollView) in
                scrollView.frame = self.computeTableViewFrame(tableView: scrollView)
            })
            self.updateMainScrollViewFrame()
            self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
            self.shouldUpdateScrollViewContentFrame = false
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Public interfaces
    open func numberOfSegments() -> Int {
        return 0
    }
    
    open func segmentTitle(forSegment index: Int) -> String {
        return ""
    }
    
    open func prepareForLayout() {
        /* to be override */
    }
    
    open func scrollView(forSegment index: Int) -> UIScrollView {
        return UITableView.init(frame: CGRect.zero, style: .grouped)
    }
}

extension TwitterProfileViewController {
    
    func prepareViews() {
        let _mainScrollView = TouchRespondScrollView(frame: self.view.bounds)
        _mainScrollView.delegate = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        
        self.mainScrollView  = _mainScrollView
        
        self.view.addSubview(_mainScrollView)
        
        _mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        // sticker header Container view
        let _stickyHeaderContainer = UIView()
        _stickyHeaderContainer.clipsToBounds = true
        _mainScrollView.addSubview(_stickyHeaderContainer)
        self.stickyHeaderContainerView = _stickyHeaderContainer
        
        // Cover Image View
        let coverImageView = RMUserCoverImageView(frame: .zero)
        coverImageView.clipsToBounds = true
        _stickyHeaderContainer.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.height.equalTo(0)
            //            make.width.equalToSuperview()
            //            make.top.equalTo(_stickyHeaderContainer)
            //            make.leading.equalTo(_stickyHeaderContainer)
            //            make.trailing.equalTo(_stickyHeaderContainer)
            //            make.edges.equalTo(_stickyHeaderContainer)
        }
        
        coverImageView.image = nil
        coverImageView.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.headerCoverView = coverImageView
        
        // ProfileHeaderView
        if let _profileHeaderView = Bundle.main.loadNibNamed("TwitterProfileHeaderView", owner: self, options: nil)?.first as? TwitterProfileHeaderView {
            _mainScrollView.addSubview(_profileHeaderView)
            self.profileHeaderView = _profileHeaderView
            self.profileHeaderView.snp.makeConstraints({ (make) in
                make.width.equalToSuperview()
            })
        }
        
        
        // Segmented Control Container
        let _segmentedControlContainer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: mainScrollView.bounds.width, height: 100))
        _segmentedControlContainer.backgroundColor = UIColor.white
        _mainScrollView.addSubview(_segmentedControlContainer)
        self.segmentedControlContainer = _segmentedControlContainer
        
        if let view = self.tabOptionsView {
            _segmentedControlContainer.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
                make.centerX.equalToSuperview()
                make.centerY.equalTo(_segmentedControlContainer.snp.centerY)
            }
            
        }
        
        self.scrollViews = []
        for index in 0..<numberOfSegments() {
            let scrollView = self.scrollView(forSegment: index)
            self.scrollViews.append(scrollView)
            scrollView.isHidden = (index > 0)
            _mainScrollView.addSubview(scrollView)
        }
        
        self.showDebugInfo()
    }
    
    func computeStickyHeaderContainerViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
    }
    
    func computeProfileHeaderViewFrame() -> CGRect {
        return CGRect(x: 0, y: computeStickyHeaderContainerViewFrame().origin.y + stickyheaderContainerViewHeight, width: mainScrollView.bounds.width, height: profileHeaderViewHeight)
    }
    
    func computeTableViewFrame(tableView: UIScrollView) -> CGRect {
        let upperViewFrame = computeSegmentedControlContainerFrame()
        return CGRect(x: 0, y: upperViewFrame.origin.y + upperViewFrame.height , width: mainScrollView.bounds.width, height: tableView.contentSize.height)
    }
    
    func computeMainScrollViewIndicatorInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.computeSegmentedControlContainerFrame().lf_originBottom, 0, 0, 0)
    }
    
    func computeNavigationFrame() -> CGRect {
        return headerCoverView.convert(headerCoverView.bounds, to: self.view)
    }
    
    func computeSegmentedControlContainerFrame() -> CGRect {
        let rect = computeProfileHeaderViewFrame()
        return CGRect(x: 0, y: rect.origin.y + rect.height, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        
    }
    
    func updateMainScrollViewFrame() {
        
        let bottomHeight = max(currentScrollView.bounds.height, 800)
        
        self.mainScrollView.contentSize = CGSize(
            width: view.bounds.width,
            height: stickyheaderContainerViewHeight + profileHeaderViewHeight + segmentedControlContainer.bounds.height + bottomHeight)
    }
}

extension TwitterProfileViewController: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset = scrollView.contentOffset
        self.debugContentOffset(contentOffset: contentOffset)
        
        // sticky headerCover
        if contentOffset.y <= 0 {
            let bounceProgress = min(1, abs(contentOffset.y) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y) + self.stickyheaderContainerViewHeight
            
            // adjust stickyHeader frame
            self.stickyHeaderContainerView.frame = CGRect(
                x: 0,
                y: contentOffset.y,
                width: mainScrollView.bounds.width,
                height: newHeight)
            
            // scaling effect
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
            // adjust mainScrollView indicator insets
            var baseInset = computeMainScrollViewIndicatorInsets()
            baseInset.top += abs(contentOffset.y)
            self.mainScrollView.scrollIndicatorInsets = baseInset
            
            self.mainScrollView.bringSubview(toFront: self.profileHeaderView)
        } else {
            
            // anything to be set if contentOffset.y is positive
            self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
        }
        
        if contentOffset.y > 0 {
            
            // When scroll View reached the threshold
            if contentOffset.y >= scrollToScaleDownProfileIconDistance {
                self.stickyHeaderContainerView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                
                // bring stickyHeader to the front
                self.mainScrollView.bringSubview(toFront: self.stickyHeaderContainerView)
            } else {
                self.mainScrollView.bringSubview(toFront: self.profileHeaderView)
                self.stickyHeaderContainerView.frame = computeStickyHeaderContainerViewFrame()
            }
            
            // Sticky Segmented Control
            let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
            let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
            let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight
            
            if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
                segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
            } else {
                segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
            }
            
        }
        // Segmented control is always on top in any situations
        self.mainScrollView.bringSubview(toFront: segmentedControlContainer)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }

}

// status bar style override
extension TwitterProfileViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// Table View Switching

extension TwitterProfileViewController {
    func updateTableViewContent() {
        print("currentIndex did changed \(self.currentIndex)")
    }
    
    @objc internal func timelineButtonTapped() {
        self.currentIndex = 0
        self.updateScrollViewContent()
    }
    
    @objc internal func basicProfileButtonTapped() {
        self.currentIndex = 1
        self.updateScrollViewContent()
    }
    
    func updateScrollViewContent(_ autoScroll: Bool = true) {
        
        let scrollViewToBeShown: UIScrollView! = self.currentScrollView
        
        self.scrollViews.forEach { (scrollView) in
            scrollView?.isHidden = scrollView != scrollViewToBeShown
        }
        
        scrollViewToBeShown.frame = self.computeTableViewFrame(tableView: scrollViewToBeShown)
        self.updateMainScrollViewFrame()
        
        // auto scroll to top if mainScrollView.contentOffset > navigationHeight + segmentedControl.height
        let navigationHeight = self.scrollToScaleDownProfileIconDistance
        let threshold = self.computeProfileHeaderViewFrame().lf_originBottom - navigationHeight
        if mainScrollView.contentOffset.y > threshold &&
            autoScroll {
            // When scroll View reached the threshold
            self.mainScrollView.setContentOffset(CGPoint(x: 0, y: threshold), animated: false)
        } else {
            let contentOffset = self.mainScrollView.contentOffset
            if contentOffset.y >= scrollToScaleDownProfileIconDistance {
                self.stickyHeaderContainerView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                // bring stickyHeader to the front
                self.mainScrollView.bringSubview(toFront: self.stickyHeaderContainerView)
            } else {
                self.mainScrollView.bringSubview(toFront: self.profileHeaderView)
                self.stickyHeaderContainerView.frame = computeStickyHeaderContainerViewFrame()
            }
            // Sticky Segmented Control
            let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
            let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
            let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight

            if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
                segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
            } else {
                segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
            }
        }
        // Segmented control is always on top in any situations
        self.mainScrollView.bringSubview(toFront: segmentedControlContainer)
    }
}

extension TwitterProfileViewController {
    
    var debugMode: Bool {
        return false
    }
    
    func showDebugInfo() {
        if debugMode {
            self.debugTextView = UILabel()
            debugTextView.text = "debug mode: on"
            debugTextView.backgroundColor = UIColor.white
            debugTextView.sizeToFit()
            
            self.view.addSubview(debugTextView)
            
            debugTextView.snp.makeConstraints({ (make) in
                make.right.equalTo(self.view.snp.right).inset(16)
                make.top.equalTo(self.view.snp.top).inset(16)
            })
        }
    }
    
    func debugContentOffset(contentOffset: CGPoint) {
        self.debugTextView?.text = "\(contentOffset)"
    }
}

extension CGRect {
    var lf_originBottom: CGFloat {
        return self.origin.y + self.height
    }
}
