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
    
    func updateToken() {
        switch token {
        case .organizationRepos(let org, _):
            token = .organizationRepos(org: org, page: page)
        case .userRepos(let user, _):
            token = .userRepos(user: user, page: page)
        case .starredRepos(let user, _):
            token = .starredRepos(user: user, page: page)
        default:
            break
        }
    }
    
    override func fetchData() {
        updateToken()
        
        GithubProvider
            .request(token)
            .do(onNext: {
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newRepos = Mapper<Repository>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newRepos
                        } else {
                            self.dataSource.value.append(contentsOf: newRepos)
                        }
                    }
                },
                onError: {
                    print($0)
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
    
    func repoViewModelForIndex(_ index: Int) -> RepositoryViewModel {
        return RepositoryViewModel(repo: dataSource.value[index])
    }
}
