//
//  Repository.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Repository: BaseModel {
    
    var id: Int?
    var name: String?
    var fullName: String?
    var repoDescription: String?
    
    var owner: User?
    var parent: Repository?
    var source: Repository?
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var isPrivate: Bool?
    var isAFork: Bool?
    var hasIssues: Bool?
    var hasWiki: Bool?
    var hasPages: Bool?
    
    var openIssuesCount: Int?
    var stargazersCount: Int?
    var forksCount: Int?
    var watchersCount: Int?
    
    var defaultBranch: String?
    
    // Mappable
    override func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
        fullName        <- map["full_name"]
        repoDescription <- map["description"]
        
        owner           <- (map["owner"], UserTransform())
        parent          <- (map["parent"], RepositoryTransform())
        source          <- (map["source"], RepositoryTransform())
        
        createdAt       <- (map["created_at"], DateTransform())
        updatedAt       <- (map["updated_at"], DateTransform())
        
        isPrivate       <- map["private"]
        isAFork         <- map["fork"]
        hasIssues       <- map["has_issues"]
        hasWiki         <- map["has_wiki"]
        hasPages        <- map["has_pages"]
        
        openIssuesCount <- map["open_issues_count"]
        stargazersCount <- map["stargazers_count"]
        forksCount      <- map["forks_count"]
        watchersCount   <- map["watchers_count"]
        
        defaultBranch   <- map["default_branch"]
    }
}