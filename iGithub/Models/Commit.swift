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
    var author: User?
    var authorName: String?
    var committer: User?
    
    override func mapping(map: Map) {
        sha         <- map["sha"]
        message     <- map["commit.message"]
        commitDate  <- (map["commit.committer.date"], DateTransform())
        author      <- map["author"]
        authorName  <- map["commit.author.name"]
        committer   <- map["committer"]
    }
    
    lazy var shortSHA: String = {
        return self.sha!.substring(to: self.sha!.characters.index(self.sha!.startIndex, offsetBy: 7))
    }()
}

class EventCommit: BaseModel {
    
    var sha: String?
    var message: String?
    
    override func mapping(map: Map) {
        sha             <- map["sha"]
        message         <- map["message"]
    }
    
    lazy var shortSHA: String = {
        return self.sha!.substring(to: self.sha!.characters.index(self.sha!.startIndex, offsetBy: 7))
    }()
}
