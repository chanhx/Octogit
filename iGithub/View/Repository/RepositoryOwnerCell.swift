//
//  RepositoryOwnerCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class RepositoryOwnerCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var entity: User! {
        didSet {
            avatarView.kf_setImageWithURL(entity.avatarURL, placeholderImage: UIImage(named: "default-avatar"))
            nameLabel.text = entity.login
        }
    }
    
}
