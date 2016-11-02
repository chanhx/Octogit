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
    
    fileprivate var token: GithubAPI
    
    init(organization: User) {
        token = .organizationRepos(org: organization.login!, page: 1)
        super.init()
    }
    
    init(user: User) {
        token = .userRepos(user: user.login!, page: 1)
        super.init()
    }
    
    init(stargazer: User) {
        token = .starredRepos(user: stargazer.login!, page: 1)
        super.init()
    }
    
    init(subscriber: User) {
        token = .subscribedRepos(user: subscriber.login!, page: 1)
        super.init()
    }
    
    private init(token: GithubAPI) {
        self.token = token
        super.init()
    }
    
    class func starred() -> RepositoryTableViewModel {
        let vm = RepositoryTableViewModel(token: .starredReposOfAuthenticatedUser(page: 1))
        return vm
    }
    
    class func subscribed() -> RepositoryTableViewModel {
        let vm = RepositoryTableViewModel(token: .subscribedReposOfAuthenticatedUser(page: 1))
        return vm
    }
    
    func updateToken() {
        switch token {
        case .organizationRepos(let org, _):
            token = .organizationRepos(org: org, page: page)
        case .userRepos(let user, _):
            token = .userRepos(user: user, page: page)
        case .starredRepos(let user, _):
            token = .starredRepos(user: user, page: page)
        case .starredReposOfAuthenticatedUser:
            token = .starredReposOfAuthenticatedUser(page: page)
        case .subscribedRepos(let user, _):
            token = .subscribedRepos(user: user, page: page)
        case .subscribedReposOfAuthenticatedUser:
            token = .subscribedReposOfAuthenticatedUser(page: page)
        default:
            break
        }
    }
    
    override func fetchData() {
        updateToken()
        
        GithubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newRepos = Mapper<Repository>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newRepos
                        } else {
                            self.dataSource.value.append(contentsOf: newRepos)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    var shouldDisplayFullName: Bool {
        switch token {
        case .organizationRepos, .userRepos:
            return false
        default:
            return true
        }
    }
    
    func repoViewModel(forRow row: Int) -> RepositoryViewModel {
        return RepositoryViewModel(repo: dataSource.value[row])
    }
}
