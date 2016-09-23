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
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = UIColor(netHex: 0x666666)
        
        metaLabel.font = UIFont.systemFont(ofSize: 14)
        metaLabel.textColor = UIColor(netHex: 0x888888)
    }
    
    func layout() {
        let vStackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, metaLabel])
        vStackView.axis = .vertical
        vStackView.alignment = .fill
        vStackView.distribution = .fill
        vStackView.spacing = 8
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vStackView)
        
        let margins = contentView.layoutMarginsGuide
        
        vStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8).isActive = true
        vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8).isActive = true
        vStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
    }
    
    func configureCell(_ name: String, description: String?, meta: String) {
        nameLabel.text = name
        metaLabel.text = meta
        
        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil
    }
}
