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
        for label in [languageLabel, stargazersCountLabel, forksCountLabel] {
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
        let hStackView = UIStackView(arrangedSubviews: [languageLabel, stargazersCountLabel, forksCountLabel])
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
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            
            vStackView.topAnchor.constraint(equalTo: iconLabel.topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            vStackView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    var entity: Repository! {
        didSet {
            nameLabel.text = shouldDisplayFullName ? entity.fullName! : entity.name!
            
            descriptionLabel.text = entity.repoDescription
            descriptionLabel.isHidden = entity.repoDescription == nil
            
            languageLabel.text = entity.language
            languageLabel.isHidden = entity.language == nil
            
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            
            stargazersCountLabel.attributedText = Octicon.star.iconString(formatter.string(from: NSNumber(value: entity.stargazersCount!))!)
            forksCountLabel.attributedText = Octicon.gitBranch.iconString(formatter.string(from: NSNumber(value: entity.forksCount!))!)
            
            if entity.isPrivate! {
                iconLabel.text = Octicon.lock.rawValue
            } else if entity.isAFork! {
                iconLabel.text = Octicon.repoForked.rawValue
            } else {
                iconLabel.text = Octicon.repo.rawValue
            }
        }
    }

}
