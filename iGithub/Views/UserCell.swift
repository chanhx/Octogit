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
        contentView.addSubviews([avatarView, nameLabel])
        
        let margins = contentView.layoutMarginsGuide
        
        avatarView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 5).active = true
        avatarView.centerYAnchor.constraintEqualToAnchor(nameLabel.centerYAnchor).active = true
        avatarView.widthAnchor.constraintEqualToConstant(32).active = true
        avatarView.heightAnchor.constraintEqualToConstant(32).active = true
        
        nameLabel.leadingAnchor.constraintEqualToAnchor(avatarView.trailingAnchor, constant: 6).active = true
        nameLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
        nameLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 6).active = true
        nameLabel.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -6).active = true
    }
    
    var entity: User! {
        didSet {
            avatarView.setAvatarWithURL(entity.avatarURL)
            nameLabel.text = entity.login
        }
    }

}
