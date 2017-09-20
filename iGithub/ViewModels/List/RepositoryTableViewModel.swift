//
//  RepositoryTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/31/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class RepositoryTableViewModel: BaseTableViewModel<Repository> {
    
    fileprivate var token: GitHubAPI
    
    init(login: String, type: RepositoryOwnerType) {
        token = .repositories(login: login, type: type, after: nil)
        super.init()
    }
    
    init(stargazer: User) {
        token = .starredRepos(user: stargazer.login!, after: nil)
        super.init()
    }
    
    init(subscriber: User) {
        token = .subscribedRepos(user: subscriber.login!, after: nil)
        super.init()
    }
    
    func updateToken() {
        switch token {
        case .repositories(let login, let type, _):
            token = .repositories(login: login, type: type, after: endCursor)
        case .starredRepos(let user, _):
            token = .starredRepos(user: user, after: endCursor)
        case .subscribedRepos(let user, _):
            token = .subscribedRepos(user: user, after: endCursor)
        default:
            break
        }
    }
    
    var ownerType: String {
        switch token {
        case .repositories(_, let type, _):
            switch type {
            case .user:
                return "user"
            case .organization:
                return "organization"
            }
        default:
            return "user"
        }
    }
    
    var key: String {
        switch token {
        case .repositories:
            return "repositories"
        case .starredRepos:
            return "starredRepositories"
        case .subscribedRepos:
            return "watching"
        default:
            return ""
        }
    }
    
    override func fetchData() {
        updateToken()
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusAndRedirectCodes()
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    
                    guard
                        let json = ($0 as? [String: [String: [String: Any]]])?["data"]?[self.ownerType]?[self.key],
                        let connection = Mapper<EntityConnection<Repository>>().map(JSONObject: json),
                        let newRepos = connection.nodes
                    else {
                        // error
//											self.error.value = Error
                        return
                    }
                    
                    self.hasNextPage = connection.pageInfo!.hasNextPage!
                    
                    if self.endCursor == nil {
                        self.dataSource.value = newRepos
                    } else {
                        self.dataSource.value.append(contentsOf: newRepos)
                    }
                    
                    self.endCursor = connection.pageInfo?.endCursor
                },
                onError: { [unowned self] in
                    self.error.value = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    var shouldDisplayFullName: Bool {
        switch token {
        case .repositories:
            return false
        default:
            return true
        }
    }
    
    func repoViewModel(forRow row: Int) -> RepositoryViewModel {
        return RepositoryViewModel(repo: dataSource.value[row])
    }
}
