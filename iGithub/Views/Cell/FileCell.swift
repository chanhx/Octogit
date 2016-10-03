//
//  FileCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
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
