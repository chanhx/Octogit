//
//  Label.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Label: BaseModel {
    
    var url: URL?
    var name: String?
    var color: String?
    
    override func mapping(map: Map) {
        url     <- (map["url"], URLTransform())
        name    <- map["name"]
        color   <- map["color"]
    }
}
