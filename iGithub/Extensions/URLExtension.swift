//
//  URLExtension.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/10/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

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
