//
//  OAuthAPI.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya

struct OAuthConfiguration {
    static let callbackMark = "iGithub"
    static let clientID = "638bff0d62dacd915554"
    static let clientSecret = "006e5bd102210c78981af47bbe347318cf55081b"
    static let scopes = ["user", "repo", "gist", "notifications"]
    static let note = "iOctocat: Application"
    static let noteURL = "http://ioctocat.com"
    static var accessToken: String?
    
    static var authorizationURL: NSURL? {
        return RxMoyaProvider<OAuthAPI>()
            .endpoint(.Authorize)
            .urlRequest
            .URL
    }
}

enum OAuthAPI {
    case Authorize
    case AccessToken(code: String)
}

extension OAuthAPI: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://github.com/login/oauth")! }
    var path: String {
        switch self {
        case .Authorize:
            return "/authorize"
        case .AccessToken(_):
            return "/access_token"
        }
    }
    var method: RxMoya.Method {
        switch self {
        case .Authorize:
            return .GET
        case .AccessToken(_):
            return .POST
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .Authorize:
            let scope = (OAuthConfiguration.scopes as NSArray).componentsJoinedByString(",")
            return ["client_id": OAuthConfiguration.clientID, "client_secret": OAuthConfiguration.clientSecret, "scope": scope]
        case .AccessToken(let code):
            return ["client_id": OAuthConfiguration.clientID, "client_secret": OAuthConfiguration.clientSecret, "code": code]
        }
    }
    var sampleData: NSData {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        }
    }
    var multipartBody: [RxMoya.MultipartFormData]? {
        switch self {
        default:
            return nil
        }
    }
}


private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}