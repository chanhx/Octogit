//
//  GithubAPI.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya

// MARK: - Provider setup

let GithubProvider = RxMoyaProvider<GithubAPI>(endpointClosure: {
    
    (target: GithubAPI) -> Endpoint<GithubAPI> in
    
    var endpoint = MoyaProvider.DefaultEndpointMapping(target)
    endpoint = endpoint.endpointByAddingParameters(["access_token": AccountManager.token!])
    
    switch target {
    case .getABlob:
        return endpoint.endpointByAddingHTTPHeaderFields(["Accept": Constants.MediaTypeRaw])
    case .getHTMLContents, .getTheREADME:
        return endpoint.endpointByAddingHTTPHeaderFields(["Accept": Constants.MediaTypeHTML])
    case .repositoryIssues, .repositoryPullRequests:
        return endpoint.endpointByAddingHTTPHeaderFields(["Accept": Constants.MediaTypeHTMLAndJSON])
    case .issueComments:
        return endpoint.endpointByAddingHTTPHeaderFields(["Accept": Constants.MediaTypeTextAndJSON])
    default:
        return endpoint
    }
})

// MARK: - Provider support

enum RepositoriesSearchSort: String {
    case bestMatch = ""
    case forks = "forks"
    case stars = "stars"
    case updated = "updated"
}

enum UsersSearchSort: String {
    case bestMatch = ""
    case followers = "followers"
    case joined = "joined"
    case repositories = "repositories"
}

enum GithubAPI {
    case followedBy(user: String, page: Int)
    case followersOf(user: String, page: Int)
    
    case getABlob(repo: String, sha: String)
    case getARepository(repo: String)
    case getContents(repo: String, path: String)
    case getHTMLContents(repo: String, path: String)
    case getTheREADME(repo: String)
    
    case issueComments(repo: String, number: Int)
    
    case oAuthUser(accessToken: String)
    
    case organization(org: String)
    case organizations(user: String)
    case organizationMembers(org: String, page: Int)
    
    case receivedEvents(user: String, page: Int)
    case userEvents(user: String, page: Int)
    case organizationEvents(org: String, page: Int)
    case repositoryEvents(repo: String, page: Int)
    
    case repositoryIssues(repo: String, page: Int, state: IssueState)
    case repositoryPullRequests(repo: String, page: Int, state: IssueState)
    
    case repositoryCommits(repo: String, branch: String, page: Int)
    case repositoryContributors(repo: String, page: Int)
    case repositoryReleases(repo: String, page: Int)
    
    case searchRepositories(q: String, sort: RepositoriesSearchSort)
    case searchUsers(q: String, sort: UsersSearchSort)
    
    case userRepos(user: String, page: Int)
    case starredRepos(user: String, page: Int)
    case organizationRepos(org: String, page: Int)
    
    case user(user: String)
    
    case userGists(user: String, page: Int)
}

extension GithubAPI: TargetType {
    
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .followedBy(let user, _):
            return "/users/\(user)/following"
        case .followersOf(let user, _):
            return "/users/\(user)/followers"
            
        case .getABlob(let repo, let sha):
            return "/repos/\(repo)/git/blobs/\(sha)"
        case .getARepository(let repo):
            return "/repos/\(repo)"
        case .getContents(let repo, let path):
            return "/repos/\(repo)/contents/\(path)"
        case .getHTMLContents(let repo, let path):
            return "/repos/\(repo)/contents/\(path)"
        case .getTheREADME(let repo):
            return "/repos/\(repo)/readme"
            
        case .issueComments(let repo, let number):
            return "/repos/\(repo)/issues/\(number)/comments"
            
        case .oAuthUser:
            return "/user"

        case .organization(let org):
            return "/orgs/\(org)"
        case .organizations(let user):
            return "/users/\(user)/orgs"
        case .organizationMembers(let org, _):
            return "/orgs/\(org)/members"
            
        case .organizationEvents(let org, _):
            return "/orgs/\(org)/events"
        case .organizationRepos(let org, _):
            return "/orgs/\(org)/repos"
            
        case .receivedEvents(let user, _):
            return "/users/\(user)/received_events"
            
        case .repositoryCommits(let repo, _, _):
            return "/repos/\(repo)/commits"
        case .repositoryContributors(let repo, _):
            return "/repos/\(repo)/contributors"
        case .repositoryEvents(let repo, _):
            return "/repos/\(repo)/events"
        case .repositoryIssues(let repo, _, _):
            return "/repos/\(repo)/issues"
        case .repositoryPullRequests(let repo, _, _):
            return "/repos/\(repo)/pulls"
        case .repositoryReleases(let repo, _):
            return "/repos/\(repo)/releases"
            
        case .searchRepositories:
            return "/search/repositories"
        case .searchUsers:
            return "/search/users"
            
        case .starredRepos(let user, _):
            return "/users/\(user)/starred"
        case .user(let user):
            return "/users/\(user)"
            
        case .userGists(let user, _):
            return "/users/\(user)/gists"
        case .userEvents(let user, _):
            return "/users/\(user)/events"
        case .userRepos(let user, _):
            return "/users/\(user)/repos"
        }
    }
    var method: RxMoya.Method {
        switch self {
        default:
            return .GET
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .oAuthUser(let accessToken):
            return ["access_token": accessToken]
            
        case .repositoryCommits(_, let branch, let page):
            return ["sha": branch, "page": page]
            
        case .searchRepositories(let q, let sort):
            return ["q": q, "sort": sort.rawValue]
            
        case .searchUsers(let q, let sort):
            return ["q": q, "sort": sort.rawValue]
            
        case .repositoryIssues(_, let page, let state),
             .repositoryPullRequests(_, let page, let state):
            return ["page": page, "state": state.rawValue]
            
        case .followedBy(_, let page),
             .followersOf(_, let page),
             
             .organizationMembers(_, let page),
             
             .receivedEvents(_, let page),
             .userEvents(_, let page),
             .organizationEvents(_, let page),
             .repositoryEvents(_, let page),
             
             .repositoryContributors(_, let page),
             .repositoryReleases(_, let page),
             
             .userGists(_, let page),
             .starredRepos(_, let page),
             .organizationRepos(_, let page),
             
             .userRepos(_, let page):
             
            return ["page": page]
            
        default:
            return nil
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
