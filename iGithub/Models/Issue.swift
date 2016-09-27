//
//  Issue.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum IssueState : String {
    case open = "open"
    case closed = "closed"
}

class Issue : BaseModel {
    
    var id: Int?
    var title: String?
    var body: String?
    var state: IssueState?
    var number: Int?
    var user: User?
    var assignees: [User]?
    var labels: [Label]?
    var milestone: Milestone?
    var createdAt: Date?
    var closedAt: Date?
    var comments: Int?
    var pullRequest: PullRequest?
    
    override func mapping(map: Map) {
        id          <- map["id"]
        number      <- map["number"]
        title       <- map["title"]
        body        <- map["body_html"]
        state       <- map["state"]
        user        <- (map["user"], UserTransform())
        assignees   <- (map["assignees"], UserTransform())
        labels      <- (map["labels"], LabelTransform())
        createdAt   <- (map["created_at"], DateTransform())
        closedAt    <- (map["closed_at"], DateTransform())
        comments    <- map["comments"]
    }
}
