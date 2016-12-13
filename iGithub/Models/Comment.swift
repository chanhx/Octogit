//
//  Comment.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Comment: Mappable {
    
    var id: Int?
    var user: User?
    var body: String?
    var createdAt: Date?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        user        <- map["user"]
        body        <- map["body_text"]
        createdAt   <- (map["created_at"], ISO8601DateTransform())
    }
}
