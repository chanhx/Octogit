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
    
    class func render(_ content: String, language: String, theme: String? = nil, showLineNumbers: Bool? = nil) -> String {
        
        let template = try! Template(named: "content")
        
        let userDefaults = UserDefaults.standard
        
        let s = showLineNumbers ?? userDefaults.bool(forKey: Constants.kLineNumbers)
        
        var t = theme ?? (userDefaults.object(forKey: Constants.kTheme) as! String)
        t = t.lowercased().replacingOccurrences(of: " ", with: "-")
        
        let data: [String: String] = [
            "theme": "prism-\(t)",
            "content": content,
            "line-numbers": s ? "class=line-numbers" : "",
            "class": language
        ]
        return try! template.render(Box(data))
    }
}
