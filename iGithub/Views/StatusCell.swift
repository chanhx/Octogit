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
        case Loading
        case Error
        case Empty
    }
    
    var name: String
    var status: Status! {
        didSet {
            switch status! {
            case .Loading:
                promptLabel.text = "Loading \(name)"
                indicator.startAnimating()
            case .Error:
                promptLabel.text = "Error loading \(name)"
                indicator.stopAnimating()
            case .Empty:
                promptLabel.text = "No \(name)"
                indicator.stopAnimating()
            }
        }
    }
    
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let promptLabel = UILabel()
    
    init(name: String, status: Status = .Loading) {
        
        self.name = name
        defer {
            self.status = status
        }
        
        super.init(style: .Default, reuseIdentifier: "StatusCell")
        
        self.userInteractionEnabled = false
        indicator.hidesWhenStopped = true
        
        contentView.addSubviews([indicator, promptLabel])
        
        let margins = contentView.layoutMarginsGuide
        
        indicator.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 3).active = true
        indicator.centerYAnchor.constraintEqualToAnchor(promptLabel.centerYAnchor).active = true
        
        promptLabel.leadingAnchor.constraintEqualToAnchor(indicator.trailingAnchor, constant: 8).active = true
        promptLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
        promptLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 6).active = true
        promptLabel.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -6).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
