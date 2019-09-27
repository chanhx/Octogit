//
//  GitHubAPI.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift

// MARK: - OAuth Configuration

struct OAuthConfiguration {
    static let callbackMark = "Octogit"
    static let clientID = "638bff0d62dacd915554"
    static let clientSecret = "006e5bd102210c78981af47bbe347318cf55081b"
    static let scopes = ["user", "repo"]
    static let note = "Octogit: Application"
    static let noteURL = "https://github.com/chanhx/Octogit"
    static var accessToken: String?
    
    static var authorizationURL: URL? {
        return try! MoyaProvider<GitHubAPI>()
            .endpoint(.authorize)
            .urlRequest()
            .url
    }
}

// MARK: - Provider setup

let GitHubProvider = MoyaProvider<GitHubAPI>().rx

// MARK: - Provider support

enum RepositoriesSearchSort: String, CustomStringConvertible {
    case bestMatch = ""
    case forks = "forks"
    case stars = "stars"
    case updated = "updated"
    
    var description: String {
        switch self {
        case .bestMatch:
            return "Best match"
        case .forks:
            return "Most forks"
        case .stars:
            return "Most stars"
        case .updated:
            return "Recently updated"
        }
    }
}

enum UsersSearchSort: String, CustomStringConvertible {
    case bestMatch = ""
    case followers = "followers"
    case joined = "joined"
    case repositories = "repositories"
    
    var description: String {
        switch self {
        case .bestMatch:
            return "Best match"
        case .followers:
            return "Most followers"
        case .repositories:
            return "Most repositories"
        case .joined:
            return "Recently joined"
        }
    }
}

enum DateRange: String {
    case today = "daily"
    case thisWeek = "weekly"
    case thisMonth = "monthly"
}

enum RepositoryOwnerType {
    case user
    case organization
}

enum GitHubAPI {
    
    // MARK: Web API
    
    case authorize
    case accessToken(code: String)
    case trending(since: DateRange, language: String, type: TrendingType)
    
    // MARK: Branch
    
    case branches(repo: String, page: Int)
    
    // MARK: File
    
    case getABlob(repo: String, sha: String)
    case getContents(repo: String, path: String, ref: String)
    case getHTMLContents(repo: String, path: String, ref: String)
    case getTheREADME(repo: String, ref: String)
    case pullRequestFiles(repo: String, number: Int, page: Int)
    
    // MARK: Comment
    
    case issueComments(repo: String, number: Int, page: Int)
    case commitComments(repo: String, sha: String, page: Int)
    case gistComments(gistID: String, page: Int)
    
    // MARK: User
    
    case oAuthUser(accessToken: String)
    case user(user: String)
    
    case organization(org: String)
    case organizations(user: String)
    case organizationMembers(org: String, page: Int)
    case repositoryContributors(repo: String, page: Int)
    
    case followedBy(user: String, page: Int)
    case followersOf(user: String, page: Int)
    
    case isFollowing(user: String)
    case follow(user: String)
    case unfollow(user: String)
    
    // MARK: Event
    
    case receivedEvents(user: String, page: Int)
    case userEvents(user: String, page: Int)
    case organizationEvents(org: String, page: Int)
    case repositoryEvents(repo: String, page: Int)
    
    // MARK: Issue & Pull Request
    
    case issues(repo: String, page: Int, state: IssueState)
    case pullRequests(repo: String, page: Int, state: IssueState)
    
    case issue(owner: String, name: String, number: Int)
    case pullRequest(owner: String, name: String, number: Int)
    
    case authenticatedUserIssues(page: Int, state: IssueState)
    
    // MARK: Commit
    
    case repositoryCommits(repo: String, sha: String, page: Int)
    case pullRequestCommits(repo: String, number: Int, page: Int)
    case commit(repo: String, sha: String)
    
    // MARK: Search
    
    case searchRepositories(query: String, after: String?)
    case searchUsers(q: String, sort: UsersSearchSort, page: Int)
    
    // MARK: Repository
    
    case repositories(login: String, type: RepositoryOwnerType, after: String?)
    case starredRepos(user: String, after: String?)
    case subscribedRepos(user: String, after: String?)
    case repository(owner: String, name: String)
    
    case star(repo: String)
    case unstar(repo: String)
    
    // MARK: Release
    
    case releases(repo: String, page: Int)
    
    // MARK: Gist
    
    case userGists(user: String, page: Int)
    case starredGists(page: Int)
}

extension GitHubAPI: TargetType {
    
    var headers: [String : String]? {
        var headers = ["Content-type": "application/json"]
        
        if let token = AccountManager.token {
            headers["Authorization"] = "token \(token)"
        }
        
        switch self {
        case .getABlob:
        	headers["Accept"] = MediaType.Raw
        case .getHTMLContents, .getTheREADME:
	        headers["Accept"] = MediaType.HTML
        case .issue, .pullRequest, .issues, .pullRequests, .issueComments:
            headers["Accept"] = MediaType.HTMLAndJSON
        case .gistComments, .commitComments:
            headers["Accept"] = MediaType.TextAndJSON
        default:
        	break
        }
        
        return headers
    }
    
    var baseURL: URL {
        switch self {
        case .authorize,
             .accessToken(code: _),
             .trending(since: _, language: _, type: _):
            
            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }
    
    var path: String {
        switch self {
            
            // MAKR: Web API
            
        case .authorize:
            return "/login/oauth/authorize"
        case .accessToken:
            return "/login/oauth/access_token"
        case .trending(_, let language, let type):
            var path: String
            switch type {
            case .repositories:
                path = "/trending"
            case .users:
                path = "/trending/developers"
            }
            
            if language.count > 0 {
                path += "/\(language)"
            }
            
            return path
            
            // MARK: Branch
            
        case .branches(let repo, _):
            return "repos/\(repo)/branches"
            
            // MARK: File
            
        case .getABlob(let repo, let sha):
            return "/repos/\(repo)/git/blobs/\(sha)"
        case .getContents(let repo, let path, _):
            return "/repos/\(repo)/contents/\(path)"
        case .getHTMLContents(let repo, let path, _):
            return "/repos/\(repo)/contents/\(path)"
        case .getTheREADME(let repo, _):
            return "/repos/\(repo)/readme"
            
        case .pullRequestFiles(let repo, let number, _):
            return "/repos/\(repo)/pulls/\(number)/files"
            
            // MARK: Comments
            
        case .issueComments(let repo, let number, _):
            return "/repos/\(repo)/issues/\(number)/comments"
        case .commitComments(let repo, let sha, _):
            return "/repos/\(repo)/commits/\(sha)/comments"
        case .gistComments(let gistID, _):
            return "/gists/\(gistID)/comments"
            
            // MARK: User
            
        case .oAuthUser:
            return "/user"
        case .user(let user):
            return "/users/\(user)"
        case .organization(let org):
            return "/orgs/\(org)"
        case .organizations(let user):
            return "/users/\(user)/orgs"
        case .organizationMembers(let org, _):
            return "/orgs/\(org)/members"
        case .repositoryContributors(let repo, _):
            return "/repos/\(repo)/contributors"
            
        case .followedBy(let user, _):
            return "/users/\(user)/following"
        case .followersOf(let user, _):
            return "/users/\(user)/followers"
            
        case .isFollowing(let user):
            return "/user/following/\(user)"
        case .follow(let user),
             .unfollow(let user):
            return "/user/following/\(user)"
            
            // MARK: Event
            
        case .receivedEvents(let user, _):
            return "/users/\(user)/received_events"
        case .userEvents(let user, _):
            return "/users/\(user)/events"
        case .repositoryEvents(let repo, _):
            return "/repos/\(repo)/events"
        case .organizationEvents(let org, _):
            return "/orgs/\(org)/events"
            
            // MARK: Issue & Pull Request
            
        case .issues(let repo, _, _):
            return "/repos/\(repo)/issues"
        case .pullRequests(let repo, _, _):
            return "/repos/\(repo)/pulls"
            
        case .issue(let owner, let name, let number):
            return "/repos/\(owner)/\(name)/issues/\(number)"
        case .pullRequest(let owner, let name, let number):
            return "/repos/\(owner)/\(name)/pulls/\(number)"
            
        case .authenticatedUserIssues:
            return "/issues"
            
            // MARK: Commit
            
        case .repositoryCommits(let repo, _, _):
            return "/repos/\(repo)/commits"
        case .pullRequestCommits(let repo, let number, _):
            return "/repos/\(repo)/pulls/\(number)/commits"
        case .commit(let repo, let sha):
            return "/repos/\(repo)/commits/\(sha)"
            
            // MARK: Search
            
        case .searchRepositories:
            return "/graphql"
        case .searchUsers:
            return "/search/users"
            
            // MARK: Repository
            
        case .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos:
            return "/graphql"
        
        case .star(let repo),
             .unstar(let repo):
            return "/user/starred/\(repo)"
            
            // MARK: Release
            
        case .releases(let repo, _):
            return "/repos/\(repo)/releases"
            
            // MARK: Gist
            
        case .userGists(let user, _):
            return "/users/\(user)/gists"
        case .starredGists:
            return "/gists/starred"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .accessToken,
             
             .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,
             
             .searchRepositories:
            return .post
        case .star,
             .follow:
            return .put
        case .unstar,
             .unfollow:
            return .delete
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
            
        case .authorize:
            let scope = (OAuthConfiguration.scopes as NSArray).componentsJoined(by: ",")
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "scope": scope as AnyObject]
            
        case .accessToken(let code):
            return ["client_id": OAuthConfiguration.clientID as AnyObject, "client_secret": OAuthConfiguration.clientSecret as AnyObject, "code": code as AnyObject]
            
        case .trending(let since, _, _):
            return ["since": since.rawValue as AnyObject]
            
        case .oAuthUser(let accessToken):
            return ["access_token": accessToken]
            
        case .repositoryCommits(_, let sha, let page):
            return ["sha": sha, "page": page]
            
        case .getContents(_, _, let ref),
             .getHTMLContents(_, _, let ref),
             .getTheREADME(_, let ref):
            return ["ref": ref]
            
        case .searchUsers(let q, let sort, let page):
            return ["q": q, "sort": sort.rawValue, "page": page]
            
        case .issues(_, let page, let state),
             .pullRequests(_, let page, let state),
             .authenticatedUserIssues(let page, let state):
            return ["page": page, "state": state.rawValue]
            
        case .branches(_, let page),
             
             .followedBy(_, let page),
             .followersOf(_, let page),
             
             .organizationMembers(_, let page),
             
             .issueComments(_, _, let page),
             .commitComments(_, _, let page),
             .gistComments(_, let page),
             
             .receivedEvents(_, let page),
             .userEvents(_, let page),
             .organizationEvents(_, let page),
             .repositoryEvents(_, let page),
             
             .pullRequestCommits(_, _, let page),
             .pullRequestFiles(_, _, let page),
             
             .repositoryContributors(_, let page),
             .releases(_, let page),
             
             .userGists(_, let page),
             .starredGists(let page):
             
            return ["page": page]
            
        case .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,
             .searchRepositories:
            return GraphQL.query(self)
            
        default:
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .accessToken,
             
             .repository,
             .repositories,
             .starredRepos,
             .subscribedRepos,
             
             .searchRepositories:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    var task: Moya.Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
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
