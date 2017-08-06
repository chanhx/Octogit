//
//  PageInfo.swift
//  iGithub
//
//  Created by Chan Hocheung on 31/07/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

struct PageInfo: Mappable {
    
	var endCursor: String?
	var startCursor: String?
	var hasNextPage: Bool?
	var hasPreviousPage: Bool?

	init?(map: Map) {
		mapping(map: map)
	}

	mutating func mapping(map: Map) {
		endCursor        <- map["endCursor"]
		startCursor      <- map["startCursor"]

		hasNextPage      <- map["hasNextPage"]
		hasPreviousPage  <- map["hasPreviousPage"]
	}
}
