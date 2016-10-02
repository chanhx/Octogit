//
//  IssueCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueCell: UITableViewCell {
    
    fileprivate let statusLabel = UILabel()
    fileprivate let titleLabel = UILabel()
    fileprivate let infoLabel = UILabel()
    fileprivate let commentsLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        statusLabel.font = UIFont.OcticonOfSize(23)
        statusLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(netHex: 0x888888)
        
        commentsLabel.textColor = UIColor(netHex: 0x888888)
        commentsLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        let hStackView = UIStackView(arrangedSubviews: [infoLabel, commentsLabel])
        hStackView.axis = .horizontal
        hStackView.alignment = .fill
        hStackView.distribution = .equalSpacing
        hStackView.spacing = 10
        
        let vStackView = UIStackView(arrangedSubviews: [titleLabel, hStackView])
        vStackView.axis = .vertical
        vStackView.alignment = .fill
        vStackView.distribution = .fill
        vStackView.spacing = 5
        
        contentView.addSubviews([statusLabel, vStackView])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            
            vStackView.topAnchor.constraint(equalTo: statusLabel.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: Issue! {
        didSet {
            titleLabel.text = entity.title
            
            if let comments = entity.comments, comments > 0 {
                commentsLabel.attributedText = Octicon.comment.iconString("\(comments)")
                commentsLabel.isHidden = false
            } else {
                commentsLabel.isHidden = true
            }
            
            let info = "#\(entity.number!) by \(entity.user!)"
            
            if let pullRequest = entity as? PullRequest {
                statusLabel.text = Octicon.gitPullrequest.rawValue
                switch entity.state! {
                case .closed:
                    if let mergedAt = pullRequest.mergedAt {
                        statusLabel.textColor = UIColor(netHex: 0x6e5494)
                        infoLabel.text = "\(info) - \(mergedAt.naturalString)"
                    } else {
                        statusLabel.textColor = UIColor(netHex: 0xbd2c00)
                        infoLabel.text = "\(info) - \(pullRequest.closedAt!.naturalString)"
                    }
                case .open:
                    statusLabel.textColor = UIColor(netHex: 0x6cc644)
                    infoLabel.text = "\(info) - \(entity.createdAt!.naturalString)"
                }
            } else {
                switch entity.state! {
                case .closed:
                    statusLabel.text = Octicon.issueClosed.rawValue
                    statusLabel.textColor = UIColor(netHex: 0xbd2c00)
                    infoLabel.text = "\(info) - \(entity.closedAt!.naturalString)"
                case .open:
                    statusLabel.text = Octicon.issueOpened.rawValue
                    statusLabel.textColor = UIColor(netHex: 0x6cc644)
                    infoLabel.text = "\(info) - \(entity.createdAt!.naturalString)"
                }
            }
        }
    }
}
