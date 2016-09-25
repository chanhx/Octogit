//
//  UIViewControllerExtension.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

extension UIViewController {
    
    // from https://github.com/p-sun/Swift2-iOS9-UI
    
    func sizeHeaderToFit(tableView: UITableView) {
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            tableView.tableHeaderView = headerView
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
}
