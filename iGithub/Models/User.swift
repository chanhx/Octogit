//
//  User.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserType: String {
    case User = "User"
    case Organization = "Organization"
}

class User: BaseModel, CustomStringConvertible {
    
    var id: Int?
    var login: String?
    var name: String?
    var avatarURL: NSURL?
    var bio: String?
    
    var gravatarID: String?
    var type: UserType?
    var company: String?
    var blog: NSURL?
    var location: String?
    var email: String?
    var orgDescription: String?
    
    var followers: Int?
    var following: Int?
    var publicGists: Int?
    var publicRepos: Int?
    
    // Mappable
    override func mapping(map: Map) {
        id              <- map["id"]
        login           <- map["login"]
        name            <- map["name"]
        avatarURL       <- (map["avatar_url"], URLTransform())
        bio             <- map["bio"]
        
        gravatarID      <- map["gravatar_id"]
        type            <- map["type"]
        company         <- map["company"]
        blog            <- (map["blog"], URLTransform())
        location        <- map["location"]
        email           <- map["email"]
        orgDescription  <- map["description"]
        
        followers       <- map["followers"]
        following       <- map["following"]
        publicGists     <- map["public_gists"]
        publicRepos     <- map["public_repos"]
    }
    
    var description : String {
        get {
            return self.login!
        }
    }
}