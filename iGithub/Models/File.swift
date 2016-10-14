//
//  File.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class File: BaseModel {
    
    enum FileType: String {
        case directory = "dir"
        case file = "file"
        case submodule = "submodule"
        case symlink = "symlink"
    }

    var type: FileType?
    var encoding: String?
    var size: Int?
    var name: String?
    var path: String?
    var content: String?
    var sha: String?
    var htmlURL: URL?
    
    override func mapping(map: Map) {
        type        <- map["type"]
        encoding    <- map["encoding"]
        size        <- map["size"]
        name        <- map["name"]
        path        <- map["path"]
        content     <- map["content"]
        sha         <- map["sha"]
        htmlURL     <- (map["html_url"], URLTransform())
    }
}
