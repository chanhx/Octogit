//
//  Release.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/6/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Release: Mappable {
    
    var name: String?
    var tagName: String?
    var body: String?
    var author: User?
    var createdAt: Date?
    var publishedAt: Date?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name        <- map["name"]
        tagName     <- map["tag_name"]
        body        <- map["body"]
        author      <- map["author"]
        createdAt   <- (map["created_at"], ISO8601DateTransform())
        publishedAt <- (map["published_at"], ISO8601DateTransform())
    }
}
