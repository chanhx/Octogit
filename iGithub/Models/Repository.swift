//
//  Repository.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Repository: Mappable {
    
    var id: Int?
    var name: String?
    var fullName: String?
    var homepage: URL?
    var repoDescription: String?
    var language: String?
    
    var owner: User?
    var parent: Repository?
    var source: Repository?
    
    var createdAt: Date?
    var pushedAt: Date?
    var updatedAt: Date?
    
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
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
        fullName        <- map["full_name"]
        homepage        <- (map["homepage"], URLTransform())
        repoDescription <- map["description"]
        language        <- map["language"]
        
        owner           <- map["owner"]
        parent          <- map["parent"]
        source          <- map["source"]
        
        createdAt       <- (map["created_at"], ISO8601DateTransform())
        pushedAt        <- (map["pushed_at"], ISO8601DateTransform())
        updatedAt       <- (map["updated_at"], ISO8601DateTransform())
        
        isPrivate       <- map["private"]
        isAFork         <- map["fork"]
        hasIssues       <- map["has_issues"]
        hasWiki         <- map["has_wiki"]
        hasPages        <- map["has_pages"]
        
        openIssuesCount <- map["open_issues_count"]
        stargazersCount <- map["stargazers_count"]
        forksCount      <- map["forks_count"]
        watchersCount   <- map["subscribers_count"]
        
        defaultBranch   <- map["default_branch"]
    }
}
