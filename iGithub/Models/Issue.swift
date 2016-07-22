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
    case Open = "open"
    case Closed = "closed"
}

class Issue : BaseModel {
    
    var id: Int?
    var title: String?
    var body: String?
    var state: IssueState?
    var number: String?
    var pullRequest: PullRequest?
    
    override func mapping(map: Map) {
        id      <- map["id"]
        number  <- map["number"]
        title   <- map["title"]
        body    <- map["body"]
        state   <- map["state"]
    }
}