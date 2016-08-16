//
//  WebAPI.swift
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
        return RxMoyaProvider<WebAPI>()
            .endpoint(.Authorize)
            .urlRequest
            .URL
    }
}

enum TrendingTime: String {
    case Today = "daily"
    case ThisWeek = "weekly"
    case ThisMonth = "monthly"
}

enum WebAPI {
    case Authorize
    case AccessToken(code: String)
    case Trending(since: TrendingTime, language: String, type: SegmentTitle)
}

extension WebAPI: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://github.com")! }
    var path: String {
        switch self {
        case .Authorize:
            return "/login/oauth/authorize"
        case .AccessToken(_):
            return "/login/oauth/access_token"
        case .Trending(_, _, let type):
            switch type {
            case .Repositories:
                return "/trending"
            case .Users:
                return "/trending/developers"
            }
        }
    }
    var method: RxMoya.Method {
        switch self {
        case .AccessToken(_):
            return .POST
        default:
            return .GET
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .Authorize:
            let scope = (OAuthConfiguration.scopes as NSArray).componentsJoinedByString(",")
            return ["client_id": OAuthConfiguration.clientID, "client_secret": OAuthConfiguration.clientSecret, "scope": scope]
        case .AccessToken(let code):
            return ["client_id": OAuthConfiguration.clientID, "client_secret": OAuthConfiguration.clientSecret, "code": code]
        case .Trending(let since, let language, _):
            return ["since": since.rawValue, "l": language]
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