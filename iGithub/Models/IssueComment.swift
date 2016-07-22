//
//  IssueComment.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class IssueComment : BaseModel {
    
    var id: Int?
    var user: User?
    var body: String?
    var createdAt: NSDate?
    
    override func mapping(map: Map) {
        id          <- map["id"]
        user        <- (map["user"], UserTransform())
        body        <- map["content"]
        createdAt   <- (map["created_at"], DateTransform())
    }
}