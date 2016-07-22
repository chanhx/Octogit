//
//  Repo.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Repo: BaseModel {
    
    var id: Int?
    var name: String?
    var fullName: String?
    var url: NSURL?
    
    // Mappable
    override func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        fullName    <- map["full_name"]
        url         <- (map["url"], URLTransform())
    }
}