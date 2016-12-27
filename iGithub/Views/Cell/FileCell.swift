//
//  FileCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {

    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configureSubviews()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        iconLabel.font = UIFont.OcticonOfSize(20)
        iconLabel.layer.masksToBounds = true
        iconLabel.layer.isOpaque = true
        iconLabel.backgroundColor = .white
        
        nameLabel.numberOfLines = 3
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = UIColor(netHex: 0x4078C0)
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.isOpaque = true
        nameLabel.backgroundColor = .white
        
        contentView.addSubviews([iconLabel, nameLabel])
    }
    
    func layout() {
        let margins = contentView.layoutMarginsGuide
        
        iconLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 3),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.topAnchor, constant: 1),
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
    
    var entity: File! {
        didSet {
            nameLabel.text = entity.name
            
            switch entity.type! {
            case .directory:
                iconLabel.text = Octicon.fileDirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x80A6CD)
            case .file:
                iconLabel.textColor = UIColor(netHex: 0x767676)
                
                switch entity.name!.pathExtension {
                case "jpg", "png", "gif", "mp3", "mp4":
                    iconLabel.text = Octicon.fileMedia.rawValue
                case "pdf":
                    iconLabel.text = Octicon.filePDF.rawValue
                case "md", "markdown", "adoc":
                    iconLabel.text = Octicon.book.rawValue
                case "rar", "zip":
                    iconLabel.text = Octicon.fileZip.rawValue
                default:
                    iconLabel.text = Octicon.fileText.rawValue
                }
            case .submodule:
                iconLabel.text = Octicon.fileSubmodule.rawValue
                nameLabel.text = "\(entity.name!) @ \(entity.shortSHA)"
                iconLabel.textColor = UIColor(netHex: 0x767676)
            case .symlink:
                iconLabel.text = Octicon.fileSymlinkDirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x767676)
            }
        }
    }

}
