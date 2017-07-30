//
//  GitHubAPI.swift
//  iGithub
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
    static let callbackMark = "iGithub"
    static let clientID = "638bff0d62dacd915554"
    static let clientSecret = "006e5bd102210c78981af47bbe347318cf55081b"
    static let scopes = ["user", "repo"]
    static let note = "iOctocat: Application"
    static let noteURL = "http://ioctocat.com"
    static var accessToken: String?
    
    static var authorizationURL: URL? {
        return GitHubProvider
            .endpoint(.authorize)
            .urlRequest?
            .url
    }
}

// MARK: - Provider setup

let GitHubProvider = RxMoyaProvider<GitHubAPI>(endpointClosure: {
    
    (target: GitHubAPI) -> Endpoint<GitHubAPI> in
    
    var endpoint = MoyaProvider.defaultEndpointMapping(for: target)
    
    if let token = AccountManager.token {
        endpoint = endpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(token)"])
    }
    
    switch target {
    case .getABlob:
        return endpoint.adding(newHTTPHeaderFields: ["Accept": Constants.MediaTypeRaw])
    case .getHTMLContents, .getTheREADME:
        return endpoint.adding(newHTTPHeaderFields: ["Accept": Constants.MediaTypeHTML])
    case .repositoryIssues, .repositoryPullRequests:
        return endpoint.adding(newHTTPHeaderFields: ["Accept": Constants.MediaTypeHTMLAndJSON])
    case .issueComments, .pullRequestComments, .gistComments, .commitComments:
        return endpoint.adding(newHTTPHeaderFields: ["Accept": Constants.MediaTypeTextAndJSON])
    default:
        return endpoint
    }
})

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

enum TrendingTime: String {
    case today = "daily"
    case thisWeek = "weekly"
    case thisMonth = "monthly"
}

enum GitHubAPI {
    
    // MARK: Web API
    
    case authorize
    case accessToken(code: String)
    case trending(since: TrendingTime, language: String, type: TrendingType)
    
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
    case pullRequestComments(repo: String, number: Int, page: Int)
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
    
    case repositoryIssues(repo: String, page: Int, state: IssueState)
    case repositoryPullRequests(repo: String, page: Int, state: IssueState)
    
    case authenticatedUserIssues(page: Int, state: IssueState)
    
    // MARK: Commit
    
    case repositoryCommits(repo: String, sha: String, page: Int)
    case pullRequestCommits(repo: String, number: Int, page: Int)
    case getACommit(repo: String, sha: String)
    
    // MARK: Search
    
    case searchRepositories(q: String, sort: RepositoriesSearchSort, page: Int)
    case searchUsers(q: String, sort: UsersSearchSort, page: Int)
    
    // MARK: Repository
    
    case userRepos(user: String, page: Int)
    case starredRepos(user: String, page: Int)
    case starredReposOfAuthenticatedUser(page: Int)
    case subscribedRepos(user: String, page: Int)
    case subscribedReposOfAuthenticatedUser(page: Int)
    case organizationRepos(org: String, page: Int)
    case repository(owner: String, name: String)
    
    case isStarring(repo: String)
    case star(repo: String)
    case unstar(repo: String)
    
    // MARK: Release
    
    case releases(repo: String, page: Int)
    
    // MARK: Gist
    
    case userGists(user: String, page: Int)
    case starredGists(page: Int)
}

extension GitHubAPI: TargetType {
    
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
        case .trending(_, _, let type):
            switch type {
            case .repositories:
                return "/trending"
            case .users:
                return "/trending/developers"
            }
            
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
        case .pullRequestComments(let repo, let number, _):
            return "/repos/\(repo)/pulls/\(number)/comments"
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
            
        case .repositoryIssues(let repo, _, _):
            return "/repos/\(repo)/issues"
        case .repositoryPullRequests(let repo, _, _):
            return "/repos/\(repo)/pulls"
            
        case .authenticatedUserIssues:
            return "/issues"
            
            // MARK: Commit
            
        case .repositoryCommits(let repo, _, _):
            return "/repos/\(repo)/commits"
        case .pullRequestCommits(let repo, let number, _):
            return "/repos/\(repo)/pulls/\(number)/commits"
        case .getACommit(let repo, let sha):
            return "/repos/\(repo)/commits/\(sha)"
            
            // MARK: Search
            
        case .searchRepositories:
            return "/search/repositories"
        case .searchUsers:
            return "/search/users"
            
            // MARK: Repository
            
        case .repository:
            return "/graphql"
        case .userRepos(let user, _):
            return "/users/\(user)/repos"
        case .organizationRepos(let org, _):
            return "/orgs/\(org)/repos"
        case .starredRepos(let user, _):
            return "/users/\(user)/starred"
        case .starredReposOfAuthenticatedUser:
            return "/user/starred"
        case .subscribedRepos(let user, _):
            return "/users/\(user)/subscriptions"
        case .subscribedReposOfAuthenticatedUser:
            return "/user/subscriptions"
            
        case .isStarring(let repo):
            return "/user/starred/\(repo)"
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
        case .accessToken, .repository:
            return .post
        case .star, .follow:
            return .put
        case .unstar, .unfollow:
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
            
        case .trending(let since, let language, _):
            return ["since": since.rawValue as AnyObject, "l": language as AnyObject]
            
        case .oAuthUser(let accessToken):
            return ["access_token": accessToken]
            
        case .repositoryCommits(_, let sha, let page):
            return ["sha": sha, "page": page]
            
        case .getContents(_, _, let ref),
             .getHTMLContents(_, _, let ref),
             .getTheREADME(_, let ref):
            return ["ref": ref]
            
        case .searchRepositories(let q, let sort, let page):
            return ["q": q, "sort": sort.rawValue, "page": page]
            
        case .searchUsers(let q, let sort, let page):
            return ["q": q, "sort": sort.rawValue, "page": page]
            
        case .repositoryIssues(_, let page, let state),
             .repositoryPullRequests(_, let page, let state),
             .authenticatedUserIssues(let page, let state):
            return ["page": page, "state": state.rawValue]
            
        case .branches(_, let page),
             
             .followedBy(_, let page),
             .followersOf(_, let page),
             
             .organizationMembers(_, let page),
             
             .issueComments(_, _, let page),
             .pullRequestComments(_, _, let page),
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
             .starredGists(let page),
             
             .userRepos(_, let page),
             .organizationRepos(_, let page),
             .starredRepos(_, let page),
             .starredReposOfAuthenticatedUser(let page),
             .subscribedRepos(_, let page),
             .subscribedReposOfAuthenticatedUser(let page):
            
            return ["page": page]
            
        case .repository:
            return GraphQL.query(self)
            
        default:
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .accessToken(_), .repository(_, _):
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    var task: Moya.Task {
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
