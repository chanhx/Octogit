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
    case idle
    case draging
    case refreshing
    case noMoreData
}

class RefreshComponent: UIView {
    
    fileprivate weak var scrollView: UIScrollView!
    fileprivate weak var target: AnyObject?
    fileprivate var selector: Selector?
    
    var state: RefreshState
    
    fileprivate let indicator = LoadingIndicator(lineWidth: 3, strokeEnd: 0.15)
    
    init(target: AnyObject?, selector: Selector?) {
        self.state = .idle
        self.target = target
        self.selector = selector
        
        super.init(frame: CGRect.zero)
        
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 26).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endRefreshing() {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
}

class RefreshHeader: RefreshComponent {
    
    fileprivate var kvoContext: UInt8 = 0
    
    override var state: RefreshState {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .idle, .noMoreData:
                if oldValue == .refreshing {
                    UIView.animate(withDuration: AnimationDuration, animations: {
                        self.scrollView.contentInset.top -= RefreshComponentHeight
                    }) 
                }
                indicator.stopAnimating()
                isHidden = true
            case .draging:
                isHidden = false
            case .refreshing:
                indicator.startAnimating()
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.scrollView.contentInset.top += RefreshComponentHeight
                }, completion: { _ in
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                }) 
            }
        }
    }
    
    deinit {
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        
        self.scrollView = scrollView
        frame = CGRect(x: 0, y: -RefreshComponentHeight, width: scrollView.bounds.width, height: RefreshComponentHeight)
        
        self.scrollView.addObserver(self, forKeyPath: RefreshContentOffsetKey, options: .new, context: &kvoContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &kvoContext else {
            return
        }
        
        switch state {
        case .refreshing:
            return
        default:
            break
        }
        
        if keyPath == RefreshContentOffsetKey {
            
            if scrollView.contentOffset.y >= -scrollView.contentInset.top {
                state = .idle
            } else if state == .draging {
                let yDiff = abs(scrollView.contentOffset.y) - scrollView.contentInset.top
                var yPercent = yDiff / RefreshComponentHeight
                
                yPercent = yPercent >= 1 ? 1 : yPercent
                indicator.updateStrokeEnd(yPercent * 0.95)
                
                if yPercent >= 1 && !scrollView.isDragging {
                    state = .refreshing
                }
            } else if scrollView?.isDragging == true {
                state = .draging
            }
        }
    }
}

class RefreshFooter: RefreshComponent {
    
    fileprivate var kvoContext: UInt8 = 0
    
    override var state: RefreshState {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .idle, .noMoreData:
                if oldValue == .refreshing {
                    UIView.animate(withDuration: AnimationDuration, animations: {
                        self.scrollView.contentInset.bottom -= RefreshComponentHeight
                    }) 
                }
                indicator.stopAnimating()
                isHidden = true
            case .draging:
                isHidden = false
            case .refreshing:
                indicator.startAnimating()
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.scrollView.contentInset.bottom += RefreshComponentHeight
                }, completion: { _ in
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                }) 
            }
        }
    }
    
    deinit {
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        superview?.removeObserver(self, forKeyPath: RefreshContentSizeKey, context: &kvoContext)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        superview?.removeObserver(self, forKeyPath: RefreshContentOffsetKey, context: &kvoContext)
        superview?.removeObserver(self, forKeyPath: RefreshContentSizeKey, context: &kvoContext)
        
        self.scrollView = scrollView
        frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: RefreshComponentHeight)
        
        self.scrollView.addObserver(self, forKeyPath: RefreshContentOffsetKey, options: .new, context: &kvoContext)
        self.scrollView.addObserver(self, forKeyPath: RefreshContentSizeKey, options: .new, context: &kvoContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &kvoContext else {
            return
        }
        
        if keyPath == RefreshContentSizeKey {
            var tmpFrame = frame
            tmpFrame.origin.y = scrollView.contentSize.height
            frame = tmpFrame
        }
        
        switch state {
        case .noMoreData, .refreshing:
            return
        default:
            break
        }
        
        if keyPath == RefreshContentOffsetKey {
            if scrollView?.isDragging == true {
                if scrollView.contentOffset.y <= scrollView.contentSize.height - scrollView.bounds.height {
                    state = .idle
                } else if state == .draging {
                    let yDiff = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height) - scrollView.contentInset.bottom
                    var yPercent = yDiff / RefreshComponentHeight
                    yPercent = yPercent >= 1 ? 1 : yPercent
                    indicator.updateStrokeEnd(yPercent * 0.95)
                    
                    if yPercent >= 1 {
                        state = .refreshing
                    }
                } else  {
                    state = .draging
                }
            }
        }
    }
}
