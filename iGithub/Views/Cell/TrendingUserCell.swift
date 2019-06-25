//
//  TrendingUserCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 2019/6/25.
//  Copyright © 2019 Hocheung. All rights reserved.
//

import Foundation

class TrendingUserCell: UITableViewCell {
    
    let avatarView = UIImageView()
    let nameLabel = UILabel()
    let loginNameLabel = UILabel()
    let repoIcon = UIImageView()
    let repoNameLabel = UILabel()
    let repoDescriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        layout()
    }
    
    func commonInit() {
        nameLabel.textColor = UIColor(netHex: 0x0366D6)
        loginNameLabel.textColor = UIColor(netHex: 0x586069)
        repoNameLabel.textColor = UIColor(netHex: 0x0366D6)
        repoDescriptionLabel.textColor = UIColor(netHex: 0x586069)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        loginNameLabel.font = UIFont.systemFont(ofSize: 16)
        repoNameLabel.font = UIFont.systemFont(ofSize: 15)
        repoDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        
        repoNameLabel.numberOfLines = 0
        repoDescriptionLabel.numberOfLines = 0
        
        for label in [nameLabel, loginNameLabel, repoNameLabel, repoDescriptionLabel] {
            label.layer.isOpaque = true
            label.backgroundColor = .white
        }
        
        repoIcon.image = Octicon.repo.image(iconSize: 20, size: CGSize(width: 20, height: 20))
        
        contentView.addSubviews([avatarView, nameLabel, loginNameLabel, repoIcon, repoNameLabel, repoDescriptionLabel])
    }
    
    func layout() {
        let avatarSize: CGFloat = 50
        let iconSize: CGFloat = 20
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            avatarView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 5),
            avatarView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarView.heightAnchor.constraint(equalToConstant: avatarSize),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 2),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -2),
            
            repoIcon.widthAnchor.constraint(equalToConstant: iconSize),
            repoIcon.heightAnchor.constraint(equalToConstant: iconSize),
            repoIcon.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 8),
            repoIcon.rightAnchor.constraint(equalTo: avatarView.rightAnchor),
            
            repoNameLabel.topAnchor.constraint(equalTo: repoIcon.topAnchor),
            repoNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: iconSize),
            repoNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            repoNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            repoDescriptionLabel.topAnchor.constraint(equalTo: repoNameLabel.bottomAnchor, constant: 5),
            repoDescriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            repoDescriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            repoDescriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8),
            ])
    }
    
    func setContentWith(user: User, repository: Repository) {
        avatarView.setAvatar(with: user.avatarURL)
        nameLabel.text = user.name
        loginNameLabel.text = user.login
        
        repoNameLabel.text = repository.name
        repoDescriptionLabel.text = repository.repoDescription
    }
}
