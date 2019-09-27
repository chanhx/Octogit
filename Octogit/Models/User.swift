//
//  User.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserType: String {
    case user = "User"
    case organization = "Organization"
}

class User: Mappable, CustomStringConvertible {
    
    var id: Int?
    var login: String!
    var name: String?
    var avatarURL: URL?
    var bio: String?
    
    var gravatarID: String?
    var type: UserType?
    var company: String?
    var blog: URL?
    var location: String?
    var email: String?
    var orgDescription: String?
    
    var followers: Int?
    var following: Int?
    var publicGists: Int?
    var publicRepos: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
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
        return self.login!
    }
}
