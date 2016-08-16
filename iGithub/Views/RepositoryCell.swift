//
//  RepositoryCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/30/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let languageLabel = UILabel()
    private let stargazersCountLabel = UILabel()
    private let forksCountLabel = UILabel()
    private let watchersCountLabel = UILabel()
    
    var shouldDisplayFullName = true

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.configureSubviews()
        self.layout()
    }
    
    func configureSubviews() {
        for label in [languageLabel, stargazersCountLabel, forksCountLabel, watchersCountLabel] {
            label.textColor = UIColor(netHex: 0x888888)
            label.font = UIFont.systemFontOfSize(14)
        }
        
        iconLabel.font = UIFont.OcticonOfSize(23)
        
        nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .ByWordWrapping
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .ByWordWrapping
        descriptionLabel.textColor = UIColor(netHex: 0x666666)
    }
    
    func layout() {
        let hStackView = UIStackView(arrangedSubviews: [languageLabel, stargazersCountLabel, forksCountLabel, watchersCountLabel])
        hStackView.axis = .Horizontal
        hStackView.alignment = .Center
        hStackView.distribution = .EqualSpacing
        hStackView.spacing = 12
        
        let vStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, hStackView])
        vStackView.axis = .Vertical
        vStackView.alignment = .Leading
        vStackView.distribution = .Fill
        vStackView.spacing = 8
        
        contentView.addSubviews([iconLabel, vStackView])
        
        let margins = contentView.layoutMarginsGuide
        
        iconLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 8).active = true
        iconLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 5).active = true
        
        vStackView.topAnchor.constraintEqualToAnchor(iconLabel.topAnchor).active = true
        vStackView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -8).active = true
        vStackView.leadingAnchor.constraintEqualToAnchor(iconLabel.trailingAnchor, constant: 8).active = true
        vStackView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
    }
    
    var entity: Repository! {
        didSet {
            nameLabel.text = shouldDisplayFullName ? entity.fullName! : entity.name!
            
            descriptionLabel.text = entity.repoDescription
            descriptionLabel.hidden = entity.repoDescription == nil
            
            languageLabel.text = entity.language
            languageLabel.hidden = entity.language == nil
            
            stargazersCountLabel.attributedText = Octicon.Star.iconString("\(entity.stargazersCount!)")
            forksCountLabel.attributedText = Octicon.RepoForked.iconString("\(entity.forksCount!)")
            watchersCountLabel.attributedText = Octicon.Eye.iconString("\(entity.watchersCount!)")
            
            if entity.isPrivate! {
                iconLabel.text = Octicon.Lock.rawValue
            } else if entity.isAFork! {
                iconLabel.text = Octicon.RepoForked.rawValue
            } else {
                iconLabel.text = Octicon.Repo.rawValue
            }
        }
    }

}
