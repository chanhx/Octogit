//
//  Constants.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/5/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

struct Constants {
    static let APIVersion = "v3"
    static let kTheme = "theme"
    static let kLineNumbers = "linenumbers"
    
    static let MediaTypeHTML = "application/vnd.github.\(APIVersion).html"
    static let MediaTypeRaw = "application/vnd.github.\(APIVersion).raw"
    static let MediaTypeHTMLAndJSON = "application/vnd.github.\(APIVersion).html+json"
    static let MediaTypeTextAndJSON = "application/vnd.github.\(APIVersion).text+json"
}
