//
//  Release.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/6/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Release: BaseModel {
    
    var name: String?
    var tagName: String?
    var body: String?
    var author: User?
    var createdAt: Date?
    var publishedAt: Date?
    
    override func mapping(map: Map) {
        name        <- map["name"]
        tagName     <- map["tag_name"]
        body        <- map["body"]
        author      <- (map["author"], UserTransform())
        createdAt   <- (map["created_at"], DateTransform())
        publishedAt <- (map["published_at"], DateTransform())
    }
}
