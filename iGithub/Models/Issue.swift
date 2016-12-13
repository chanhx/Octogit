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

class Issue: Mappable {
    
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
    var pullRequest: [String: String]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        number      <- map["number"]
        title       <- map["title"]
        body        <- map["body_html"]
        state       <- map["state"]
        user        <- map["user"]
        assignees   <- map["assignees"]
        milestone   <- map["milestone"]
        labels      <- map["labels"]
        createdAt   <- (map["created_at"], ISO8601DateTransform())
        closedAt    <- (map["closed_at"], ISO8601DateTransform())
        comments    <- map["comments"]
        pullRequest <- map["pull_request"]
    }
    
    var icon: Octicon {
        switch state! {
        case .closed:
            return .issueClosed
        case .open:
            return .issueOpened
        }
    }
    
    var iconColor: UIColor {
        switch state! {
        case .closed:
            return UIColor(netHex: 0xbd2c00)
        case .open:
            return UIColor(netHex: 0x6cc644)
        }
    }
    
    var isPullRequest: Bool {
        if let _ = pullRequest {
            return true
        }
        
        return false
    }
}
