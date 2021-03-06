//
//  CommitFile.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class CommitFile: Mappable {
    
    enum Status: String {
        case added = "added"
        case removed = "removed"
        case modified = "modified"
        case renamed = "renamed"
    }
    
    var path: String?
    var sha: String?
    var status: Status?
    var additions: Int?
    var deletions: Int?
    var changes: Int?
    var patch: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        path        <- map["filename"]
        sha         <- map["sha"]
        status      <- map["status"]
        additions   <- map["additions"]
        deletions   <- map["deletions"]
        changes     <- map["changes"]
        patch       <- map["patch"]
    }
    
    var name: String {
        return path!.components(separatedBy: "/").last!
    }
}
