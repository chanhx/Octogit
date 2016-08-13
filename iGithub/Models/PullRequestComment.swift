//
//  PullRequestComment.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class PullRequestComment : BaseModel {
    
    var id: Int?
    var diffHunk: String?
    var path: String?
    var position: Int?
    var originalPosition: Int?
    var commitID: String?
    var originalCommitID: String?
    
    var body: String?
    var user: User?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var pullRequestURL: NSURL?
    
    override func mapping(map: Map) {
        id      <- map["id"]
        diffHunk    <- map["diff_hunk"]
        path        <- map["path"]
        position    <- map["position"]
        originalPosition    <- map["original_position"]
        commitID            <- map["commit_id"]
        originalCommitID    <- map["original_commit_id"]
        
        body    <- map["body"]
        user    <- (map["user"], UserTransform())
        createdAt   <- (map["created_at"], DateTransform())
        updatedAt   <- (map["updated_at"], DateTransform())
        
        pullRequestURL  <- (map["pull_request"], URLTransform())
    }
}