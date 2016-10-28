//
//  Milestone.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Milestone: Mappable {
    
    typealias MilestoneState = IssueState
    
    var number: Int?
    var state: MilestoneState?
    var title: String?
    var milestoneDesc: String?
    var creator: User?
    var openIssues: Int?
    var closedIssues: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        number          <- map["number"]
        state           <- map["state"]
        title           <- map["title"]
        milestoneDesc   <- map["description"]
        creator         <- map["creator"]
        openIssues      <- map["open_issues"]
        closedIssues    <- map["closed_issues"]
    }
}
