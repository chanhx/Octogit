//
//  UserCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    let avatarView = UIImageView()
    let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        
        let views = ["avatarView": avatarView, "nameLabel": nameLabel]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-13-[avatarView(32)]-6-[nameLabel]-15-|", options: [], metrics: [:], views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[avatarView(32)]", options: [], metrics: [:], views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-14-[nameLabel]-14-|", options: [], metrics: [:], views: views))
        contentView.addConstraint(NSLayoutConstraint(
            item: avatarView, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: nameLabel, attribute: .CenterY,
            multiplier: 1, constant: 0))
    }
    
    var entity: User! {
        didSet {
            avatarView.setAvatarWithURL(entity.avatarURL)
            nameLabel.text = entity.login
        }
    }

}
