//
//  RepositoryCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/30/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    fileprivate let iconLabel = UILabel()
    fileprivate let nameLabel = UILabel()
    fileprivate let descriptionLabel = UILabel()
    fileprivate let languageLabel = UILabel()
    fileprivate let stargazersCountLabel = UILabel()
    fileprivate let forksCountLabel = UILabel()
    fileprivate let watchersCountLabel = UILabel()
    
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
            label.font = UIFont.systemFont(ofSize: 14)
        }
        
        iconLabel.font = UIFont.OcticonOfSize(23)
        
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = UIColor(netHex: 0x666666)
    }
    
    func layout() {
        let hStackView = UIStackView(arrangedSubviews: [languageLabel, stargazersCountLabel, forksCountLabel, watchersCountLabel])
        hStackView.axis = .horizontal
        hStackView.alignment = .center
        hStackView.distribution = .equalSpacing
        hStackView.spacing = 12
        
        let vStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, hStackView])
        vStackView.axis = .vertical
        vStackView.alignment = .leading
        vStackView.distribution = .fill
        vStackView.spacing = 8
        
        contentView.addSubviews([iconLabel, vStackView])
        
        let margins = contentView.layoutMarginsGuide
        
        iconLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8).isActive = true
        iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 5).isActive = true
        
        vStackView.topAnchor.constraint(equalTo: iconLabel.topAnchor).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8).isActive = true
        vStackView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
    }
    
    var entity: Repository! {
        didSet {
            nameLabel.text = shouldDisplayFullName ? entity.fullName! : entity.name!
            
            descriptionLabel.text = entity.repoDescription
            descriptionLabel.isHidden = entity.repoDescription == nil
            
            languageLabel.text = entity.language
            languageLabel.isHidden = entity.language == nil
            
            stargazersCountLabel.attributedText = Octicon.star.iconString("\(entity.stargazersCount!)")
            forksCountLabel.attributedText = Octicon.repoforked.iconString("\(entity.forksCount!)")
            watchersCountLabel.attributedText = Octicon.eye.iconString("\(entity.watchersCount!)")
            
            if entity.isPrivate! {
                iconLabel.text = Octicon.lock.rawValue
            } else if entity.isAFork! {
                iconLabel.text = Octicon.repoforked.rawValue
            } else {
                iconLabel.text = Octicon.repo.rawValue
            }
        }
    }

}
