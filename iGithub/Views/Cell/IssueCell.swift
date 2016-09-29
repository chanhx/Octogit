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
        
        contentView.addSubviews([statusLabel, titleLabel, hStackView])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: statusLabel.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            
            hStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            hStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8),
            hStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    var entity: Issue! {
        didSet {
            titleLabel.text = entity.title
            commentsLabel.attributedText = Octicon.comment.iconString("\(entity.comments!)")
            commentsLabel.isHidden = entity.comments == 0
            let info = "#\(entity.number!) by \(entity.user!)"
            
            switch entity.state! {
            case .closed:
                statusLabel.text = Octicon.issueclosed.rawValue
                statusLabel.textColor = UIColor(netHex: 0xBD2C00)
                infoLabel.text = "\(info) - \(entity.closedAt!.naturalString)"
            case .open:
                statusLabel.text = Octicon.issueopened.rawValue
                statusLabel.textColor = UIColor(netHex: 0x6CC644)
                infoLabel.text = "\(info) - \(entity.createdAt!.naturalString)"
            }
        }
    }
}
