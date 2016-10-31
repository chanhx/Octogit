//
//  LibraryCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 31/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class LibraryCell: UITableViewCell {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    var entity: Repository! {
        didSet {
            nameLabel.text = entity.name
            descriptionLabel.text = entity.repoDescription
        }
    }
}
