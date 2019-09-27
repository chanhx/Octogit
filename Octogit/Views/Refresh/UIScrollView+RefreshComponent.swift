//
//  UIScrollView+RefreshComponent.swift
//  Octogit
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
            insertSubview(newValue!, at: 0)
            
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
            insertSubview(newValue!, at: 0)
            
            objc_setAssociatedObject(self, &RefreshFooterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var dataCount: Int {
        var count = 0
        if let tableView = self as? UITableView {
            for section in 0 ..< tableView.numberOfSections{
                count += tableView.numberOfRows(inSection: section)
            }
        } else if let collectionView = self as? UICollectionView {
            for section in 0 ..< collectionView.numberOfSections {
                count += collectionView.numberOfItems(inSection: section)
            }
        }
        
        return count
    }
}
