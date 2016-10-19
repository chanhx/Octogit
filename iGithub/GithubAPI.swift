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
    case .issueComments, .gistComments, .commitComments:
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
    
    // MARK: Branch
    
    case branches(repo: String, page: Int)
    
    // MARK: File
    
    case getABlob(repo: String, sha: String)
    case getContents(repo: String, path: String, ref: String)
    case getHTMLContents(repo: String, path: String, ref: String)
    case getTheREADME(repo: String)
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
    
    // MARK: Event
    
    case receivedEvents(user: String, page: Int)
    case userEvents(user: String, page: Int)
    case organizationEvents(org: String, page: Int)
    case repositoryEvents(repo: String, page: Int)
    
    // MARK: Issue & Pull Request
    
    case repositoryIssues(repo: String, page: Int, state: IssueState)
    case repositoryPullRequests(repo: String, page: Int, state: IssueState)
    
    // MARK: Commit
    
    case repositoryCommits(repo: String, branch: String, page: Int)
    case pullRequestCommits(repo: String, number: Int, page: Int)
    case getACommit(repo: String, sha: String)
    
    // MARK: Search
    
    case searchRepositories(q: String, sort: RepositoriesSearchSort)
    case searchUsers(q: String, sort: UsersSearchSort)
    
    // MARK: Repository
    
    case userRepos(user: String, page: Int)
    case starredRepos(user: String, page: Int)
    case organizationRepos(org: String, page: Int)
    case getARepository(repo: String)
    
    // MARK: Release
    
    case releases(repo: String, page: Int)
    
    // MARK: Gist
    
    case userGists(user: String, page: Int)
    case starredGists(page: Int)
}

extension GithubAPI: TargetType {
    
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    var path: String {
        switch self {
            
        // MARK: Branch
        
        case .branches(let repo, _):
            return "repos/\(repo)/branches"
            
        // MARK: File
            
        case .getABlob(let repo, let sha):
            return "/repos/\(repo)/git/blobs/\(sha)"
        case .getARepository(let repo):
            return "/repos/\(repo)"
        case .getContents(let repo, let path, _):
            return "/repos/\(repo)/contents/\(path)"
        case .getHTMLContents(let repo, let path, _):
            return "/repos/\(repo)/contents/\(path)"
        case .getTheREADME(let repo):
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
            
        case .userRepos(let user, _):
            return "/users/\(user)/repos"
        case .organizationRepos(let org, _):
            return "/orgs/\(org)/repos"
        case .starredRepos(let user, _):
            return "/users/\(user)/starred"
            
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
            
        case .getContents(_, _, let ref),
             .getHTMLContents(_, _, let ref):
            return ["ref": ref]
            
        case .searchRepositories(let q, let sort):
            return ["q": q, "sort": sort.rawValue]
            
        case .searchUsers(let q, let sort):
            return ["q": q, "sort": sort.rawValue]
            
        case .repositoryIssues(_, let page, let state),
             .repositoryPullRequests(_, let page, let state):
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
             .starredGists(let page),
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
