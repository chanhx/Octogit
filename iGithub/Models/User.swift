//
//  User.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var id: Int?
    var login: String?
    var name: String?
    var avatarURL: NSURL?
    
    var gravatarID: String?
    var type: String?
    var company: String?
    var blog: String?
    var location: String?
    var email: String?
    
    var HTMLURL: NSURL?
    
    var followers: Int?
    var following: Int?
    var publicGists: Int?
    var publicRepos: Int?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id          <- map["id"]
        login       <- map["login"]
        name        <- map["name"]
        avatarURL   <- (map["avatar_url"], URLTransform())
        
        gravatarID  <- map["gravatar_id"]
        type        <- map["type"]
        company     <- map["company"]
        blog        <- map["blog"]
        location    <- map["location"]
        email       <- map["email"]
        
        HTMLURL     <- (map["url"], URLTransform())
        
        followers   <- map["followers"]
        following   <- map["following"]
        publicGists <- map["public_gists"]
        publicRepos <- map["public_repos"]
    }
}