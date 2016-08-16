//
//  UserTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class UserTableViewModel: BaseTableViewModel<User> {
    
    private var token: GithubAPI
    
    init(repo: Repository) {
        token = .RepositoryContributors(repo: repo.fullName!)
        super.init()
    }
    
    init(organization: User) {
        token = .Members(org: organization.login!)
        super.init()
    }
    
    init(user: User) {
        token = .Organizations(user: user.login!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newUsers = Mapper<User>().mapArray($0) {
                        self.dataSource.value.appendContentsOf(newUsers)
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    func userViewModelForIndex(index: Int) -> UserViewModel {
        return UserViewModel(dataSource.value[index])
    }
}
