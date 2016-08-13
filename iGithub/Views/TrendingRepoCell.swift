//
//  TrendingRepoCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/13/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class TrendingRepoCell: UITableViewCell {
    
//    let numberLabel = UILabel()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let metaLabel = UILabel()

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
        nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .ByWordWrapping
        descriptionLabel.textColor = UIColor(netHex: 0x666666)
        
        metaLabel.font = UIFont.systemFontOfSize(14)
        metaLabel.textColor = UIColor(netHex: 0x888888)
    }
    
    func layout() {
        let vStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, metaLabel])
        vStackView.axis = .Vertical
        vStackView.alignment = .Fill
        vStackView.distribution = .Fill
        vStackView.spacing = 8
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vStackView)
        
        let margins = contentView.layoutMarginsGuide
        
        vStackView.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 8).active = true
        vStackView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -8).active = true
        vStackView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 8).active = true
        vStackView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
    }
    
    func configureCell(name: String, description: String?, meta: String) {
        nameLabel.text = name
        metaLabel.text = meta
        
        descriptionLabel.text = description
        descriptionLabel.hidden = description == nil
    }
}
