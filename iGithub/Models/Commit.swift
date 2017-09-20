//
//  Commit.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Commit: Mappable {
    
    var sha: String!
    var message: String?
    var commitDate: Date?
    var countOfChanges: Int?
    var author: User?
    var authorName: String?
    var committer: User?
    var files: [CommitFile]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        sha         <- map["sha"]
        message     <- map["commit.message"]
        commitDate  <- (map["commit.author.date"], ISO8601DateTransform())
        author      <- map["author"]
        authorName  <- map["commit.author.name"]
        committer   <- map["committer"]
        files       <- map["files"]
    }
    
    lazy var shortSHA: String = {
        return self.sha!.substring(to: 7)
    }()
}

class EventCommit: Mappable {
    
    var sha: String?
    var message: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        sha             <- map["sha"]
        message         <- map["message"]
    }
    
    lazy var shortSHA: String = {
        return self.sha!.substring(to: 7)
    }()
}
