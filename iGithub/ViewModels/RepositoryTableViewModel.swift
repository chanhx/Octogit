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
    
    private var token: GithubAPI
    
    init(organization: User) {
        token = .OrganizationRepos(org: organization.login!)
        super.init()
    }
    
    init(user: User) {
        token = .UserRepos(user: user.login!)
        super.init()
    }
    
    init(stargazer: User) {
        token = .StarredRepos(user: stargazer.login!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newRepos = Mapper<Repository>().mapArray($0) {
                        self.dataSource.value.appendContentsOf(newRepos)
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    var shouldDisplayFullName: Bool {
        switch token {
        case .OrganizationRepos, .UserRepos:
            return false
        default:
            return true
        }
    }
    
    func repoViewModelForIndex(index: Int) -> RepositoryViewModel {
        return RepositoryViewModel(repo: dataSource.value[index])
    }
}
