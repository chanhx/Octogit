//
//  PullRequest.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class PullRequest : Issue {
    
    var isMerged: Bool?
    var mergedAt: Date?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        isMerged <- map["merged"]
        mergedAt <- (map["merged_at"], DateTransform())
    }
}
