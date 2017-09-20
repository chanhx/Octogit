//
//  CommitCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class CommitCell: UITableViewCell {
    
    fileprivate let avatarView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let infoLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(netHex: 0x333333)
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.isOpaque = true
        titleLabel.backgroundColor = .white
        
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(netHex: 0x767676)
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.layer.isOpaque = true
        infoLabel.backgroundColor = .white
        
        contentView.addSubviews([avatarView, titleLabel, infoLabel])
    }
    
    func layout() {        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: margins.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11),
            avatarView.heightAnchor.constraint(equalToConstant: 36),
            avatarView.widthAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: Commit! {
        didSet {
            avatarView.setAvatar(with: entity.author?.avatarURL)
            titleLabel.text = entity.message?.replacingOccurrences(of: "\n\n", with: "\n")
            
            let author = entity.author?.login ?? entity.authorName
            infoLabel.text = "\(entity.shortSHA) by \(author!) \(entity.commitDate!.naturalString(withPreposition: true))"
        }
    }
}
