//
//  InfoNumberCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 20/09/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation

class InfoNumberCell: UITableViewCell {
    
	let infoLabel = UILabel()
    private let numberLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        infoLabel.layer.isOpaque = true
        infoLabel.backgroundColor = .white
        
        let numberLabelHeight: CGFloat = 20
        
        numberLabel.font = UIFont.systemFont(ofSize: 16)
        numberLabel.textColor = UIColor(netHex: 0x464F58)
        numberLabel.backgroundColor = UIColor(netHex: 0xE8E9EA)
        numberLabel.layer.cornerRadius = numberLabelHeight / 2
        numberLabel.layer.masksToBounds = true
        
        contentView.addSubviews([infoLabel, numberLabel])
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11.5),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11.5),
            
            numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor),
            numberLabel.heightAnchor.constraint(equalToConstant: numberLabelHeight)
        ])
    }
    
    var number: Int? {
        didSet {
            guard let number = number else { return }
            
            numberLabel.text = "  \(number)  "
            numberLabel.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        numberLabel.isHidden = true
    }
}
