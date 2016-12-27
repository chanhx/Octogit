//
//  ReleaseCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/6/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class ReleaseCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        nameLabel.layer.isOpaque = true
        nameLabel.backgroundColor = .white
        
        [tagLabel, timeLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = UIColor(netHex: 0x767676)
            $0.layer.isOpaque = true
            $0.backgroundColor = .white
        }
    }
    
    func layout() {
        let hStackView = UIStackView(arrangedSubviews: [tagLabel, timeLabel])
        hStackView.axis = .horizontal
        hStackView.distribution = .fill
        hStackView.alignment = .fill
        hStackView.spacing = 12
        
        let vStackView = UIStackView(arrangedSubviews: [nameLabel, hStackView])
        vStackView.axis = .vertical
        vStackView.distribution = .fill
        vStackView.alignment = .leading
        vStackView.spacing = 8
        
        contentView.addSubviews([vStackView])
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: Release! {
        didSet {
            if let name = entity.name,
                name.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
                nameLabel.text = entity.name
            } else {
                nameLabel.text = entity.tagName
            }
            
            tagLabel.attributedText = Octicon.tag.iconString(entity.tagName!, iconColor: UIColor(netHex: 0x767676))
            timeLabel.attributedText = Octicon.clock.iconString(entity.publishedAt!.naturalString, iconColor: UIColor(netHex: 0x767676))
        }
    }
}
