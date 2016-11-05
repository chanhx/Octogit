//
//  TrendingRepoCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/13/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class TrendingRepoCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let languageLabel = UILabel()
    private let stargazersCountLabel = UILabel()
    private let forksCountLabel = UILabel()
    private let periodStargazersCountLabel = UILabel()

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
        for label in [periodStargazersCountLabel, languageLabel, stargazersCountLabel, forksCountLabel] {
            label.textColor = UIColor(netHex: 0x888888)
            label.font = UIFont.systemFont(ofSize: 14)
        }
        
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
        
        let vStackView = UIStackView(arrangedSubviews: [periodStargazersCountLabel, nameLabel, descriptionLabel, hStackView])
        vStackView.axis = .vertical
        vStackView.alignment = .leading
        vStackView.distribution = .fill
        vStackView.spacing = 8
        
        contentView.addSubview(vStackView)
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8),
            vStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8)
        ])
    }
    
    func configureCell(name: String, description: String?, language: String?, stargazers: String, forks: String, periodStargazers: String?) {
        nameLabel.text = name
        
        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil
        
        languageLabel.text = language
        languageLabel.isHidden = language == nil
        
        periodStargazersCountLabel.text = periodStargazers
        periodStargazersCountLabel.isHidden = periodStargazers == nil
        
        stargazersCountLabel.attributedText = Octicon.star.iconString(stargazers)
        forksCountLabel.attributedText = Octicon.gitBranch.iconString(forks)
    }
}
