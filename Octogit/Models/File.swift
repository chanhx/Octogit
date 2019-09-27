//
//  File.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class File: Mappable {
    
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

    var link: URL?
    var gitLink: URL?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        type        <- map["type"]
        encoding    <- map["encoding"]
        size        <- map["size"]
        name        <- map["name"]
        path        <- map["path"]
        content     <- map["content"]
        sha         <- map["sha"]
        
        link    <- (map["_links.self"], URLTransform())
        gitLink     <- (map["_links.git"], URLTransform())
    }
    
    lazy var isSubmodule: Bool = {
        guard self.type == .file else {
            return false
        }
        
        guard self.size! <= 0 else {
            return false
        }
        
        guard let l1 = self.link, let l2 = self.gitLink else {
            return true
        }
        
        let l1Components = l1.pathComponents
        let l2Components = l2.pathComponents
        
        return (l1Components[2] != l2Components[2])
            || (l1Components[3] != l2Components[3])
    }()
}
