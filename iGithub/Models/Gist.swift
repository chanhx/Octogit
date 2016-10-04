//
//  Gist.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class Gist: BaseModel {
    var id: String?
    var gistDescription: String?
    var isPublic: Bool?
    var isTruncated: Bool?
    var owner: User?
    var files: [GistFile]?
//    var files: [String: GistFile]?
    var comments: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    override func mapping(map: Map) {
        id              <- map["id"]
        gistDescription <- map["description"]
        isPublic        <- map["public"]
        isTruncated     <- map["truncated"]
        owner           <- (map["owner"], UserTransform())
        files           <- (map["files"], GistFilesTransform())
        comments        <- map["comments"]
        createdAt       <- (map["created_at"], DateTransform())
        updatedAt       <- (map["updated_at"], DateTransform())
    }
}

class GistFile: BaseModel {
    var name: String?
    var size: Int?
    var rawURL: URL?
    var isTruncated: Bool?
    var type: String?
    var language: String?
    
    override func mapping(map: Map) {
        name        <- map["filename"]
        size        <- map["size"]
        rawURL      <- (map["raw_url"], URLTransform())
        isTruncated <- map["truncated"]
        type        <- map["type"]
        language    <- map["language"]
    }
}
