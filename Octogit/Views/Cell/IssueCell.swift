//
//  IssueCell.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueCell: UITableViewCell {
    
    private let iconLabel = UILabel()
    private let numberLabel = UILabel()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let commentsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        iconLabel.font = UIFont.OcticonOfSize(21)
        iconLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        iconLabel.layer.isOpaque = true
        iconLabel.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.layer.isOpaque = true
        titleLabel.layer.masksToBounds = true
        titleLabel.backgroundColor = .white
        
        numberLabel.textColor = UIColor.gray
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        numberLabel.layer.isOpaque = true
        numberLabel.backgroundColor = .white
        
        commentsLabel.textAlignment = .right
        
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        
        for label in [infoLabel, commentsLabel] {
            label.textColor = UIColor(netHex: 0x888888)
            label.font = UIFont.systemFont(ofSize: 14)
            label.layer.isOpaque = true
            label.backgroundColor = .white
        }
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        let hStackView = UIStackView(arrangedSubviews: [numberLabel, commentsLabel])
        hStackView.axis = .horizontal
        hStackView.distribution = .equalSpacing
        hStackView.alignment = .center
        hStackView.spacing = 10
        
        let vStackView = UIStackView(arrangedSubviews: [hStackView, titleLabel, infoLabel])
        vStackView.axis = .vertical
        vStackView.spacing = 6
        
        contentView.addSubviews([iconLabel, vStackView])
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            
            vStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: Issue! {
        didSet {
            numberLabel.text = "#\(entity.number!)"
            
            titleLabel.text = entity.title!
            
            if let comments = entity.comments, comments > 0 {
                commentsLabel.attributedText = Octicon.comment.iconString("\(comments)")
                commentsLabel.isHidden = false
            } else {
                commentsLabel.isHidden = true
            }
            
            iconLabel.text = entity.icon.rawValue
            iconLabel.textColor = entity.iconColor
            
            switch entity.state! {
            case .closed:
                if let pullRequest = entity as? PullRequest, let mergedAt = pullRequest.mergedAt {
                    infoLabel.text = "by \(entity.author!) was merged \(mergedAt.naturalString(withPreposition: true))"
                } else {
                    infoLabel.text = "by \(entity.author!) was closed \(entity.closedAt!.naturalString(withPreposition: true))"
                }
            case .open:
                infoLabel.text = "by \(entity.author!) - \(entity.createdAt!.naturalString())"
            }
        }
    }
}
