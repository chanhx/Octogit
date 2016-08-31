//
//  RefreshComponent.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

let RefreshComponentHeight: CGFloat = 60

enum RefreshState {
    case Idle
    case Draging
    case WillRefresh
    case Refreshing
    case NoMoreData
}

class RefreshComponent: UIView {
    
//    init(target: AnyObject?, selector: Selector?) {
//        
//        state = .Idle
//        self.target = target
//        self.selector = selector
//        
//        super.init(frame: CGRectZero)
//        
//        addSubview(indicator)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
//        indicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
//        indicator.startAnimating()
//        
//        hidden = true
//    }
    
    weak var scrollView: UIScrollView!
}
