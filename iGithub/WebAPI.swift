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
    
    static var authorizationURL: URL? {
        return WebProvider
            .endpoint(.authorize)
            .urlRequest
            .url
    }
}

// MARK: - Provider setup

let WebProvider = RxMoyaProvider<WebAPI>()

// MARK: - Provider support

enum TrendingTime: String {
    case today = "daily"
    case thisWeek = "weekly"
    case thisMonth = "monthly"
}

enum WebAPI {
    case authorize
    case accessToken(code: String)
    case trending(since: TrendingTime, language: String, type: TrendingType)
}

extension WebAPI: TargetType {
    var baseURL: URL { return URL(string: "https://github.com")! }
    var path: String {
        switch self {
        case .authorize:
            return "/login/oauth/authorize"
        case .accessToken:
            return "/login/oauth/access_token"
        case .trending(_, _, let type):
            switch type {
            case .repositories:
                return "/trending"
            case .users:
                return "/trending/developers"
            }
        }
    }
    var method: RxMoya.Method {
        switch self {
        case .accessToken(_):
            return .POST
        default:
            return .GET
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .authorize:
            let scope = (OAuthConfiguration.scopes as NSArray).componentsJoined(by: ",")
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "scope": scope as AnyObject]
        case .accessToken(let code):
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "code": code as AnyObject]
        case .trending(let since, let language, _):
            return ["since": since.rawValue as AnyObject, "l": language as AnyObject]
        }
    }
    var task: RxMoya.Task {
        return .request
    }
    var sampleData: Data {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        }
    }
}


private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}
