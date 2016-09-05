//
//  Renderer.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/5/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Mustache

class Renderer {
    
    class func render(content: String, language: String, theme: String? = nil, showLineNumbers: Bool? = nil) -> String {
        
        let template = try! Template(named: "content")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let s = showLineNumbers ?? userDefaults.boolForKey(Constants.kLineNumbers)
        
        var t = theme ?? (userDefaults.objectForKey(Constants.kTheme) as! String)
        t = t.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "-")
        
        let data: [String: AnyObject] = [
            "theme": "prism-\(t)",
            "content": content,
            "line-numbers": s ? "class=line-numbers" : "",
            "class": language
        ]
        return try! template.render(Box(data))
    }
}