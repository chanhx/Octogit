//
//  CommentCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/26/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    fileprivate let avatarView = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let timeLabel = UILabel()
    fileprivate let bodyLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        nameLabel.font = .systemFont(ofSize: 15, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x555555)
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = UIColor(netHex: 0x767676)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = UIColor(netHex: 0x333333)
        
        contentView.addSubviews([avatarView, nameLabel, timeLabel, bodyLabel])
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        avatarView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        avatarView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        bodyLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
    }
    
    var entity: IssueComment! {
        didSet {
            avatarView.setAvatar(with: entity.user?.avatarURL)
            nameLabel.text = entity.user?.login
            timeLabel.text = entity.createdAt?.naturalString
            bodyLabel.text = entity.body
        }
    }
}
