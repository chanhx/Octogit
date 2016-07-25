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
                if entity.size == 0 {
                    iconLabel.text = Octicon.FileSubmodule.rawValue
                    return
                }
                iconLabel.text = Octicon.FileText.rawValue
                iconLabel.textColor = UIColor(netHex: 0x767676)
                
//                let suffix = entity.name?.componentsSeparatedByString(".").last
//                guard suffix != nil else {
//                    iconLabel.text = Octicon.FileText.rawValue
//                    return
//                }
//                
//                switch suffix! {
//                case "gif", "jpg", "png", "mp3", "mp4":
//                    iconLabel.text = Octicon.FileMedia.rawValue
//                case "pdf":
//                    iconLabel.text = Octicon.FilePdf.rawValue
//                case "rar", "zip":
//                    iconLabel.text = Octicon.FileZip.rawValue
//                default:
//                    iconLabel.text = Octicon.FileText.rawValue
//                }
//                iconLabel.textColor = UIColor(rgba: "#767676")
            case .Submodule:
                iconLabel.text = Octicon.FileSubmodule.rawValue
            case .Symlink:
                iconLabel.text = Octicon.FileSymlinkDirectory.rawValue
            }
        }
    }

}
