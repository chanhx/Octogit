//
//  PullRequest.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class PullRequest: Issue {
    
    var isMerged: Bool?
    var mergedAt: Date?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        isMerged <- map["merged"]
        mergedAt <- (map["merged_at"], DateTransform())
    }
    
    override var icon: Octicon {
        return .gitPullrequest
    }
    
    override var iconColor: UIColor {
        switch state! {
        case .closed:
            if mergedAt != nil {
                return UIColor(netHex: 0x6e5494)
            } else {
                return UIColor(netHex: 0xbd2c00)
            }
        case .open:
            return UIColor(netHex: 0x6cc644)
        }
    }
    
    override var isPullRequest: Bool {
        return true
    }
}
