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
    
    init(organization: User) {
        token = .Members(organization: organization.login!)
        super.init()
    }
    
    init(user: User) {
        token = .Organizations(username: user.login!)
        super.init()
    }
    
    override func fetchData() {
        provider
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
