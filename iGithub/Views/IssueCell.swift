//
//  IssueCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueCell: UITableViewCell {
    
    private let statusLabel = UILabel()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let commentsLabel = UILabel()

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
        statusLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        
        infoLabel.font = UIFont.systemFontOfSize(14)
        infoLabel.textColor = UIColor(netHex: 0x888888)
        
        commentsLabel.textColor = UIColor(netHex: 0x888888)
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        let hStackView = UIStackView(arrangedSubviews: [infoLabel, commentsLabel])
        hStackView.axis = .Horizontal
        hStackView.alignment = .Fill
        hStackView.distribution = .EqualSpacing
        hStackView.spacing = 10
        
        contentView.addSubviews([statusLabel, titleLabel, hStackView])
        
        statusLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 8).active = true
        statusLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 5).active = true
        
        titleLabel.topAnchor.constraintEqualToAnchor(statusLabel.topAnchor).active = true
        titleLabel.leadingAnchor.constraintEqualToAnchor(statusLabel.trailingAnchor, constant: 8).active = true
        titleLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
        
        hStackView.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 5).active = true
        hStackView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -8).active = true
        hStackView.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor).active = true
        hStackView.trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor).active = true
    }
    
    var entity: Issue! {
        didSet {
            switch entity.state! {
            case .Closed:
                statusLabel.text = Octicon.IssueClosed.rawValue
                statusLabel.textColor = UIColor(netHex: 0xBD2C00)
            case .Open:
                statusLabel.text = Octicon.IssueOpened.rawValue
                statusLabel.textColor = UIColor(netHex: 0x6CC644)
            }
            
            titleLabel.text = entity.title
            infoLabel.text = "#\(entity.number!) by \(entity.user!) - \(entity.createdAt!.naturalString)"
            
            commentsLabel.attributedText = Octicon.Comment.iconString("\(entity.comments!)")
            commentsLabel.hidden = entity.comments == 0
        }
    }
}
