//
//  Constants.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/5/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

struct Constants {
    static let kTheme = "theme"
    static let kLineNumbers = "linenumbers"
    
    private static let APIVersion = "v3"
    private static let MediaTypePrefix = "application/vnd.github.\(APIVersion)"
    
    static let MediaTypeHTML = "\(MediaTypePrefix).html"
    static let MediaTypeRaw = "\(MediaTypePrefix).raw"
    static let MediaTypeHTMLAndJSON = "\(MediaTypePrefix).html+json"
    static let MediaTypeTextAndJSON = "\(MediaTypePrefix).text+json"
}
