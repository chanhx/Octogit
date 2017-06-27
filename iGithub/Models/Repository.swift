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
    
    var name: String?
    var nameWithOwner: String?
    var homepage: URL?
    var repoDescription: String?
    var primaryLanguage: String?
    
    var owner: User?
    var parent: Repository?
    
    var pushedAt: Date?
    
    var hasStarred: Bool?
    
    var isPrivate: Bool?
    var isFork: Bool?
    var isLocked: Bool?
    var isMirror: Bool?
    
    var hasIssuesEnabled: Bool?
    var hasWikiEnabled: Bool?
    
    var openIssuesCount: Int?
    var openPRsCount: Int?
    
    var stargazersCount: Int?
    var forksCount: Int?
    var watchersCount: Int?
    
    var defaultBranch: String?
    
    var diskUsage: Int?     // kilobytes
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        name                 <- map["name"]
        nameWithOwner        <- map["nameWithOwner"]
        homepage             <- (map["homepageUrl"], URLTransform())
        repoDescription      <- map["description"]
        primaryLanguage      <- map["primaryLanguage.name"]
        
        owner                <- map["owner"]
        parent               <- map["parent"]
        
        pushedAt             <- (map["pushedAt"], ISO8601DateTransform())
        
        hasStarred           <- map["viewerHasStarred"]
        
        isPrivate            <- map["isPrivate"]
        isFork               <- map["isFork"]
        isLocked             <- map["isLocked"]
        hasIssuesEnabled     <- map["hasIssuesEnabled"]
        hasWikiEnabled       <- map["hasWikiEnabled"]
        
        openIssuesCount      <- map["issues.totalCount"]
        openPRsCount         <- map["pullRequests.totalCount"]
        
        stargazersCount      <- map["stargazers.totalCount"]
        forksCount           <- map["forks.totalCount"]
        watchersCount        <- map["watchers.totalCount"]
        
        defaultBranch        <- map["defaultBranchRef.name"]
        
        diskUsage            <- map["diskUsage"]
    }
}
