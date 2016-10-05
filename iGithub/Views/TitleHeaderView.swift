//
//  TitleHeaderView.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/4/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class TitleHeaderView: UIView {

    let iconLabel = UILabel()
    let titleLabel = UILabel()
    let avatarView = UIImageView()
    let infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(netHex: 0xEFEFF4)
        
        configureSubviews()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        iconLabel.font = UIFont.OcticonOfSize(23)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        infoLabel.textColor = UIColor(netHex: 0x767676)
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        
        addSubviews([iconLabel, titleLabel, avatarView, infoLabel])
    }
    
    func layout() {
        let margins = layoutMarginsGuide
        
        iconLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        iconLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        infoLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
            iconLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            avatarView.heightAnchor.constraint(equalToConstant: 20),
            avatarView.widthAnchor.constraint(equalToConstant: 20),
            avatarView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            avatarView.leadingAnchor.constraint(equalTo: iconLabel.leadingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 5),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -5)
        ])
    }

}
