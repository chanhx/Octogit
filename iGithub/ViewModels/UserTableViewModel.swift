//
//  UserTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class UserTableViewModel: BaseTableViewModel<User> {
    
    fileprivate var token: GithubAPI
    
    init(repo: Repository) {
        token = .repositoryContributors(repo: repo.fullName!)
        super.init()
    }
    
    init(organization: User) {
        token = .members(org: organization.login!)
        super.init()
    }
    
    init(user: User) {
        token = .organizations(user: user.login!)
        super.init()
    }
    
    init(followedBy user: User) {
        token = .followedBy(user: user.login!)
        super.init()
    }
    
    init(followersOf user: User) {
        token = .followersOf(user: user.login!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe {
                if let newUsers = Mapper<User>().mapArray(JSONObject: $0) {
                    self.dataSource.value.append(contentsOf: newUsers)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func userViewModelForIndex(_ index: Int) -> UserViewModel {
        return UserViewModel(dataSource.value[index])
    }
}
