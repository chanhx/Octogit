//
//  ModelExtension.swift
//  Octogit
//
//  Created by Chan Hocheung on 06/08/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation

extension Repository {
    
    var icon: Octicon {
        if isPrivate! {
            return Octicon.lock
        } else if isFork! {
            return Octicon.repoForked
        } else if isMirror! {
            return Octicon.mirror
        } else {
            return Octicon.repo
        }
    }
}
