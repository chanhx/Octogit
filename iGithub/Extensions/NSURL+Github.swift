//
//  NSURL+Github.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/10/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension NSURL {
    var isGithubURL: Bool {
        return host == "github.com" || host == "gist.github.com" || absoluteString.hasPrefix("/")
    }
}