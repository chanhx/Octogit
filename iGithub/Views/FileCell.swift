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
                iconLabel.text = Octicon.filedirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x80A6CD)
            case .file:
                iconLabel.textColor = UIColor(netHex: 0x767676)
                
                switch entity.name!.pathExtension {
                case "jpg", "png", "gif", "mp3", "mp4":
                    iconLabel.text = Octicon.filemedia.rawValue
                case "pdf":
                    iconLabel.text = Octicon.filepdf.rawValue
                case "md", "markdown", "adoc":
                    iconLabel.text = Octicon.book.rawValue
                case "rar", "zip":
                    iconLabel.text = Octicon.filezip.rawValue
                default:
                    iconLabel.text = Octicon.filetext.rawValue
                }
            case .submodule:
                iconLabel.text = Octicon.filesubmodule.rawValue
                nameLabel.text = "\(entity.name!) @ \(entity.shortenSHA)"
                iconLabel.textColor = UIColor(netHex: 0x767676)
            case .symlink:
                iconLabel.text = Octicon.filesymlinkdirectory.rawValue
                iconLabel.textColor = UIColor(netHex: 0x767676)
            }
        }
    }

}
