//
//  GistCell.swift
//  Octogit
//
//  Created by Chan Hocheung on 10/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import UIKit

class GistCell: UITableViewCell {
    
    fileprivate let nameLabel = UILabel()
    fileprivate let filesCountLabel = UILabel()
    fileprivate let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        nameLabel.numberOfLines = 3
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        nameLabel.layer.isOpaque = true
        nameLabel.backgroundColor = .white
        
        [filesCountLabel, timeLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = UIColor(netHex: 0x767676)
            $0.layer.isOpaque = true
            $0.backgroundColor = .white
        }
    }
    
    func layout() {
        filesCountLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        timeLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [filesCountLabel, timeLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        
        contentView.addSubviews([nameLabel, stackView])
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: Gist! {
        didSet {
            nameLabel.text = entity.files?[0].name
            
            filesCountLabel.attributedText = Octicon.gist.iconString("\(entity.files!.count)")
            timeLabel.attributedText = Octicon.clock.iconString(entity.updatedAt!.naturalString())
        }
    }
}
