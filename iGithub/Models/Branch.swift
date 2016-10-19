//
//  Branch.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/18/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Branch: BaseModel {
    
    var name: String?
    var commitSHA: String?
    var isProtected: Bool?
    
    override func mapping(map: Map) {
        name        <- map["name"]
        commitSHA   <- map["commit.sha"]
        isProtected <- map["protected"]
    }
}
