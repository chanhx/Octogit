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
        token = .organizationRepos(org: organization.login!)
        super.init()
    }
    
    init(user: User) {
        token = .userRepos(user: user.login!)
        super.init()
    }
    
    init(stargazer: User) {
        token = .starredRepos(user: stargazer.login!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newRepos = Mapper<Repository>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newRepos)
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
