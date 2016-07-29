//
//  EventCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import SwiftDate

class EventCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var distanceFromDetail: NSLayoutConstraint!
    
    var entity: Event! {
        didSet {
            avatarView.setAvatarWithURL(entity.actor!.avatarURL)
            timeLabel.text = entity.createdAt!.naturalString
            
            titleLabel.text = entity.title
            
            contentLabel.text = entity.content
            distanceFromDetail.constant = contentLabel.text == nil ? 0 : 8
        }
    }
    
}
