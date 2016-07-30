//
//  StatusCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let promptLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicator)
        contentView.addSubview(promptLabel)
        
        let views = ["indicator": indicator, "promptLabel": promptLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-16-[indicator]-8-[promptLabel]-16-|", options: [], metrics: [:], views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-14-[promptLabel]-14-|", options: [], metrics: [:], views: views))
        contentView.addConstraint(NSLayoutConstraint(
            item: indicator, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: promptLabel, attribute: .CenterY,
            multiplier: 1, constant: 0))
    }
    
}
