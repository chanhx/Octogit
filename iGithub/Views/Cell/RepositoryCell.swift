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
    private let infoLabel = UILabel()
    
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
        for label in [infoLabel, languageLabel, stargazersCountLabel, forksCountLabel] {
            label.textColor = UIColor(netHex: 0x888888)
            label.font = UIFont.systemFont(ofSize: 14)
            label.layer.isOpaque = true
            label.backgroundColor = .white
        }
        
        iconLabel.font = UIFont.OcticonOfSize(23)
        iconLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        iconLabel.layer.isOpaque = true
        iconLabel.backgroundColor = .white
        
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.layer.isOpaque = true
        nameLabel.backgroundColor = .white
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = UIColor(netHex: 0x666666)
        descriptionLabel.layer.isOpaque = true
        descriptionLabel.layer.masksToBounds = true
        descriptionLabel.backgroundColor = .white
    }
    
    func layout() {
        let hStackView = UIStackView(arrangedSubviews: [languageLabel, stargazersCountLabel, forksCountLabel])
        hStackView.axis = .horizontal
        hStackView.alignment = .center
        hStackView.distribution = .equalSpacing
        hStackView.spacing = 12
        
        let vStackView = UIStackView(arrangedSubviews: [infoLabel, nameLabel, descriptionLabel, hStackView])
        vStackView.axis = .vertical
        vStackView.alignment = .leading
        vStackView.distribution = .fill
        vStackView.spacing = 8
        
        contentView.addSubviews([iconLabel, vStackView])
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 3),
            
            vStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            vStackView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    var entity: Repository! {
        didSet {
            infoLabel.text = entity.pushedAt?.naturalString
            if shouldDisplayFullName {
                nameLabel.attributedText = highlightRepoName(fullName: entity.fullName!)
            } else {
                nameLabel.text = entity.name!
            }
            
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
    
    func configureCell(name: String, description: String?, language: String?, stargazers: String, forks: String?, periodStargazers: String?) {
        iconLabel.isHidden = true
        nameLabel.attributedText = highlightRepoName(fullName: name)
        
        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil
        
        languageLabel.text = language
        languageLabel.isHidden = language == nil
        
        infoLabel.text = periodStargazers
        infoLabel.isHidden = periodStargazers == nil
        
        stargazersCountLabel.attributedText = Octicon.star.iconString(stargazers)
        
        forksCountLabel.isHidden = forks == nil
        if let forks = forks {
            forksCountLabel.attributedText = Octicon.gitBranch.iconString(forks)
        }
    }
    
    private func highlightRepoName(fullName name: String) -> NSAttributedString {
        let nameComponents = name.components(separatedBy: "/")
        let owner = nameComponents[0]
        let repo = nameComponents[1]
        let attributedName = NSMutableAttributedString(string: "\(owner) / ")
        attributedName.append(NSAttributedString(string: repo,
                                                 attributes: [
                                                    NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
                                                    NSForegroundColorAttributeName: UIColor(netHex: 0x437abe)
            ]))
        
        return attributedName
    }

}
