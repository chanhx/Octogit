//
//  StatusCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {

    enum Status {
        case loading
        case error
        case empty
    }
    
    var name: String
    var status: Status! {
        didSet {
            switch status! {
            case .loading:
                promptLabel.text = "Loading \(name)"
                indicator.startAnimating()
            case .error:
                promptLabel.text = "Error loading \(name)"
                indicator.stopAnimating()
            case .empty:
                promptLabel.text = "No \(name)"
                indicator.stopAnimating()
            }
        }
    }
    
    fileprivate let indicator = UIActivityIndicatorView(style: .gray)
    fileprivate let promptLabel = UILabel()
    
    init(name: String, status: Status = .loading) {
        
        self.name = name
        defer {
            self.status = status
        }
        
        super.init(style: .default, reuseIdentifier: "StatusCell")
        
        self.isUserInteractionEnabled = false
        indicator.hidesWhenStopped = true
        
        contentView.addSubviews([indicator, promptLabel])
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 3),
            indicator.centerYAnchor.constraint(equalTo: promptLabel.centerYAnchor),
            
            promptLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 8),
            promptLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            promptLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 6),
            promptLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -6)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
