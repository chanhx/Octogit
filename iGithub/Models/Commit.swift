//
//  Commit.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Commit: BaseModel {
    
    var sha: String?
    var message: String?
    var commitDate: Date?
    var countOfChanges: Int?
    var authorName: String?
    var committerName: String?
    
    override func mapping(map: Map) {
        sha             <- map["sha"]
        message         <- map["commit.message"]
        commitDate      <- (map["commit.author.date"], DateTransform())
        authorName      <- map["commit.author.name"]
        committerName   <- map["commit.committer.name"]
    }
}

class CommitsItem: BaseModel {
    
    var sha: String?
    var message: String?
    
    override func mapping(map: Map) {
        sha             <- map["sha"]
        message         <- map["message"]
    }
}
