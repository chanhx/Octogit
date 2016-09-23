//
//  CommitComment.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class CommitComment: BaseModel {
    
    var id: Int?
    var commitID: String?
    var user: User?
    var body: String?
    var createdAt: Date?
        
    override func mapping(map: Map) {
        id          <- map["id"]
        commitID    <- map["commit_id"]
        user        <- (map["user"], UserTransform())
        body        <- map["body"]
        createdAt   <- (map["created_at"], DateTransform())
    }
}
