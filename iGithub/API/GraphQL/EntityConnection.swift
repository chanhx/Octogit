//
//  EntityConnection.swift
//  iGithub
//
//  Created by Chan Hocheung on 31/07/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

struct EntityConnection<Entity: Mappable>: Mappable {
    
    var nodes: [Entity]?
    
    var pageInfo: PageInfo?
    var totalCount: Int?
    
    var totalDiskUsage: Int?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        
        nodes           <- map["nodes"]
        pageInfo        <- map["pageInfo"]
        
        totalCount      <- map["totalCount"]
        totalDiskUsage  <- map["totalDiskUsage"]
    }
}
