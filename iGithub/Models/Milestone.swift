//
//  Milestone.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Milestone: BaseModel {
    
    var number: Int?
    var state: IssueState?
    var title: String?
    var milestoneDesc: String?
    var openIssues: Int?
    var closedIssues: Int?
    
    override func mapping(map: Map) {
        number          <- map["number"]
        state           <- map["state"]
        title           <- map["title"]
        milestoneDesc   <- map["description"]
        openIssues      <- map["open_issues"]
        closedIssues    <- map["closed_issues"]
    }
}
