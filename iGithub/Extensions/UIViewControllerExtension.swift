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
    
    func show(indicator: LoadingIndicator, onView holdingView: UIView? = nil, size: CGFloat = 30) {

        guard let view = holdingView ?? self.view else {
            return
        }
        
        view.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.heightAnchor.constraint(equalToConstant: size),
            indicator.widthAnchor.constraint(equalToConstant: size)
        ])
        
        indicator.startAnimating()
    }
}
