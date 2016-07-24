//
//  EventCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate

class EventCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var distanceFromDetail: NSLayoutConstraint!
    
    var entity: Event! {
        didSet {
            avatarView.kf_setImageWithURL(entity.actor!.avatarURL, placeholderImage: UIImage(named: "default-avatar"))
            timeLabel.text = entity.createdAt!.naturalString
            
            titleLabel.text = entity.title
            
            contentLabel.text = entity.content
            distanceFromDetail.constant = contentLabel.text == nil ? 0 : 8
        }
    }
    
}
