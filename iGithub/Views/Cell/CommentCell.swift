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
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        self.contentView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        self.configureSubviews()
        self.layout()
    }
    
    func configureSubviews() {
        nameLabel.font = .systemFont(ofSize: 15, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x555555)
        nameLabel.layer.isOpaque = true
        nameLabel.backgroundColor = contentView.backgroundColor
        
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = UIColor(netHex: 0x767676)
        timeLabel.layer.isOpaque = true
        timeLabel.backgroundColor = contentView.backgroundColor
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = UIColor(netHex: 0x333333)
        bodyLabel.layer.isOpaque = true
        bodyLabel.backgroundColor = contentView.backgroundColor
        
        contentView.addSubviews([avatarView, nameLabel, timeLabel, bodyLabel])
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: margins.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: 36),
            avatarView.widthAnchor.constraint(equalToConstant: 36),
            
            nameLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            bodyLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            bodyLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    var entity: Comment! {
        didSet {
            avatarView.setAvatar(with: entity.user?.avatarURL)
            nameLabel.text = entity.user?.login
            timeLabel.text = entity.createdAt?.naturalString()
            bodyLabel.text = entity.body
        }
    }
}
