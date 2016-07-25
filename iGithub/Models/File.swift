//
//  File.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum FileType: String {
    case Directory = "dir"
    case File = "file"
    case Submodule = "submodule"
    case Symlink = "symlink"
}

class File: BaseModel {
    var type: FileType?
    var encoding: String?
    var size: Int?
    var name: String?
    var path: String?
    var content: String?
    var sha: String?
    var htmlURL: NSURL?
    
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
