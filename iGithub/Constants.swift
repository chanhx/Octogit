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
    
    static let APIVersion = "v3"
}

struct MediaType {
    private static let Prefix = "application/vnd.github.\(Constants.APIVersion)"
    
    static let HTML = "\(Prefix).html"
    static let Raw = "\(Prefix).raw"
    static let HTMLAndJSON = "\(Prefix).html+json"
    static let TextAndJSON = "\(Prefix).text+json"
}
