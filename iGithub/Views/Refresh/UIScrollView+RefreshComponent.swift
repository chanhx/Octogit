//
//  UIScrollView+RefreshComponent.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

var RefreshHeaderKey = "refreshHeader"
var RefreshFooterKey = "refreshFooter"

extension UIScrollView {
    
    var refreshHeader: RefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &RefreshHeaderKey) as? RefreshHeader
        }
        
        set {
            guard newValue != refreshHeader else {
                return
            }
            
            refreshHeader?.removeFromSuperview()
            insertSubview(newValue!, atIndex: 0)
            
            objc_setAssociatedObject(self, &RefreshHeaderKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var refreshFooter: RefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &RefreshFooterKey) as? RefreshFooter
        }
        
        set {
            guard newValue != refreshFooter else {
                return
            }
            
            refreshFooter?.removeFromSuperview()
            insertSubview(newValue!, atIndex: 0)
            
            objc_setAssociatedObject(self, &RefreshFooterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}