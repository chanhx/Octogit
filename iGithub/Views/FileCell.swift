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
            case .Directory:
                iconLabel.text = Octicon.FileDirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x80A6CD)
            case .File:
                iconLabel.textColor = UIColor(netHex: 0x767676)
                
                switch entity.name!.pathExtension {
                case "gif", "jpg", "png", "mp3", "mp4":
                    iconLabel.text = Octicon.FileMedia.rawValue
                case "pdf":
                    iconLabel.text = Octicon.FilePdf.rawValue
                case "rar", "zip":
                    iconLabel.text = Octicon.FileZip.rawValue
                default:
                    iconLabel.text = Octicon.FileText.rawValue
                }
            case .Submodule:
                iconLabel.text = Octicon.FileSubmodule.rawValue
                iconLabel.textColor = UIColor(netHex: 0x767676)
            case .Symlink:
                iconLabel.text = Octicon.FileSymlinkDirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x767676)
            }
        }
    }

}
