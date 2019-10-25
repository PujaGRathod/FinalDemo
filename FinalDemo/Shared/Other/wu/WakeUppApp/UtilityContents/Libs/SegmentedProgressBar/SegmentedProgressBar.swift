//
//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView
{
    var isSkeep:Bool = false
    weak var delegate: SegmentedProgressBarDelegate?
    var topColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    
    var bottomColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    
    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
    //private let duration: TimeInterval
    let arrDurations : Array<TimeInterval>
    private var hasDoneLayout = false // hacky way to prevent layouting again
    private var currentAnimationIndex = 0
    
    init(numberOfSegments: Int, /*duration: TimeInterval = 5.0*/ durations: Array<TimeInterval>) {
        //self.duration = duration
        self.arrDurations = durations
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    func startSetupAnimation()
    {
        layoutSubviews()
    }
    

    
    func animateSegment(animationIndex: Int = 0)
    {
        print(animationIndex)
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        UIView.animate(withDuration: self.arrDurations[animationIndex], delay: 0.0, options: .curveLinear, animations: {
            self.isPaused = false
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        })
        {(finished) in
            self.isPaused = true
            if(self.isSkeep == true) {
                self.next()
            }
            else {
                self.currentAnimationIndex = self.currentAnimationIndex + 1
                self.next()
            }
        }
    }
    
    private func updateColors() {
        for segment in segments
        {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        self.isSkeep = false
        if self.currentAnimationIndex < self.segments.count
        {
            self.delegate?.segmentedProgressBarChangedIndex(index: self.currentAnimationIndex)
        }
        else
        {
            self.delegate?.segmentedProgressBarFinished()
        }
    }

    func skip()
    {
        if self.currentAnimationIndex < self.segments.count{
            self.isSkeep = true
            let currentSegment = segments[currentAnimationIndex]
            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
            currentSegment.topSegmentView.layer.removeAllAnimations()
            self.isPaused = true
            self.currentAnimationIndex = self.currentAnimationIndex + 1
        }else{
            self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    func rewind() 
    {
        
        if self.currentAnimationIndex == self.segments.count{
            self.currentAnimationIndex -= 1
        }
            self.isSkeep = true
            var currentSegment = self.segments[self.currentAnimationIndex]
            currentSegment.topSegmentView.layer.removeAllAnimations()
            currentSegment.topSegmentView.frame.size.width = 0
            
            self.currentAnimationIndex = self.currentAnimationIndex - 1
            if self.currentAnimationIndex < 0{
                self.currentAnimationIndex = 0
            }
            currentSegment = self.segments[self.currentAnimationIndex]
            currentSegment.topSegmentView.layer.removeAllAnimations()
            currentSegment.topSegmentView.frame.size.width = 0
        
    }
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}
