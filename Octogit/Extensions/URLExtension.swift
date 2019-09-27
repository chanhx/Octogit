//
//  URLExtension.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/10/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension URL {
    
    var isGithubURL: Bool {
        return host == "github.com" || absoluteString.hasPrefix("/")
    }
    
    var isGistURL: Bool {
        return host == "gist.github.com"
    }
    
    var isLocalURL: Bool {
        return scheme == "file"
    }
}
