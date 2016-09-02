//
//  RefreshComponent.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

let RefreshComponentHeight: CGFloat = 50
let AnimationDuration = 0.25

var RefreshContentOffsetKey = "contentOffset"
var RefreshContentSizeKey = "contentSize"

enum RefreshState {
    case Idle
    case Draging
    case Refreshing
    case NoMoreData
}

class RefreshComponent: UIView {
    
    private weak var scrollView: UIScrollView!
    private weak var target: AnyObject?
    private var selector: Selector?
    
    private var state: RefreshState
    
    private let indicator = LoadingIndicator(lineWidth: 3, strokeEnd: 0.15)
    
    init(target: AnyObject?, selector: Selector?) {
        self.state = .Idle
        self.target = target
        self.selector = selector
        
        super.init(frame: CGRectZero)
        
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        indicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        indicator.heightAnchor.constraintEqualToConstant(30).active = true
        indicator.widthAnchor.constraintEqualToConstant(30).active = true
        
        hidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endRefreshing() {
        dispatch_async(dispatch_get_main_queue()) {
            self.state = .Idle
        }
    }
}

class RefreshHeader: RefreshComponent {
    
    private var kvoContext: UInt8 = 0
    
    override var state: RefreshState {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .Idle, .NoMoreData:
                if oldValue == .Refreshing {
                    UIView.animateWithDuration(AnimationDuration) {
                        self.scrollView.contentInset.top -= RefreshComponentHeight
                    }
                }
                indicator.stopAnimating()
                hidden = true
            case .Draging:
                hidden = false
            case .Refreshing:
                indicator.startAnimating()
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self.scrollView.contentInset.top += RefreshComponentHeight
                }) { _ in
                    if let selector = self.selector {
                        self.target?.performSelector(selector)
                    }
                }
            }
        }
    }
    
    deinit {
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        
        self.scrollView = scrollView
        frame = CGRect(x: 0, y: -RefreshComponentHeight, width: scrollView.bounds.width, height: RefreshComponentHeight)
        
        self.scrollView.addObserver(self, forKeyPath: RefreshContentOffsetKey, options: .New, context: &kvoContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard context == &kvoContext else {
            return
        }
        
        switch state {
        case .Refreshing:
            return
        default:
            break
        }
        
        if keyPath == RefreshContentOffsetKey {
            
            if scrollView.contentOffset.y >= -scrollView.contentInset.top {
                state = .Idle
            } else if state == .Draging {
                let yDiff = abs(scrollView.contentOffset.y) - scrollView.contentInset.top
                var yPercent = yDiff / RefreshComponentHeight
                
                yPercent = yPercent >= 1 ? 1 : yPercent
                indicator.updateStrokeEnd(yPercent * 0.95)
                
                if yPercent >= 1 && !scrollView.dragging {
                    state = .Refreshing
                }
            } else if scrollView?.dragging == true {
                state = .Draging
            }
        }
    }
}

class RefreshFooter: RefreshComponent {
    
    private var kvoContext: UInt8 = 0
    
    override var state: RefreshState {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .Idle, .NoMoreData:
                if oldValue == .Refreshing {
                    UIView.animateWithDuration(AnimationDuration) {
                        self.scrollView.contentInset.bottom -= RefreshComponentHeight
                    }
                }
                indicator.stopAnimating()
                hidden = true
            case .Draging:
                hidden = false
            case .Refreshing:
                indicator.startAnimating()
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self.scrollView.contentInset.bottom += RefreshComponentHeight
                }) { _ in
                    if let selector = self.selector {
                        self.target?.performSelector(selector)
                    }
                }
            }
        }
    }
    
    deinit {
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        superview?.removeObserver(self, forKeyPath: RefreshContentSizeKey, context: &kvoContext)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        superview?.removeObserver(self, forKeyPath: RefreshContentSizeKey, context: &kvoContext)
        
        self.scrollView = scrollView
        frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: RefreshComponentHeight)
        
        self.scrollView.addObserver(self, forKeyPath: RefreshContentOffsetKey, options: .New, context: &kvoContext)
        self.scrollView.addObserver(self, forKeyPath: RefreshContentSizeKey, options: .New, context: &kvoContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard context == &kvoContext else {
            return
        }
        
        if keyPath == RefreshContentSizeKey {
            var tmpFrame = frame
            tmpFrame.origin.y = scrollView.contentSize.height
            frame = tmpFrame
        }
        
        switch state {
        case .NoMoreData, .Refreshing:
            return
        default:
            break
        }
        
        if keyPath == RefreshContentOffsetKey {
            if scrollView?.dragging == true {
                if scrollView.contentOffset.y <= scrollView.contentSize.height - scrollView.bounds.height {
                    state = .Idle
                } else if state == .Draging {
                    let yDiff = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height) - scrollView.contentInset.bottom
                    var yPercent = yDiff / RefreshComponentHeight
                    yPercent = yPercent >= 1 ? 1 : yPercent
                    indicator.updateStrokeEnd(yPercent * 0.95)
                    
                    if yPercent >= 1 {
                        state = .Refreshing
                    }
                } else  {
                    state = .Draging
                }
            }
        }
    }
}