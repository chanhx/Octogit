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
        token = .repositoryContributors(repo: repo.fullName!, page: 1)
        super.init()
    }
    
    init(organization: User) {
        token = .organizationMembers(org: organization.login!, page: 1)
        super.init()
    }
    
    init(user: User) {
        token = .organizations(user: user.login!)
        super.init()
    }
    
    init(followedBy user: User) {
        token = .followedBy(user: user.login!, page: 1)
        super.init()
    }
    
    init(followersOf user: User) {
        token = .followersOf(user: user.login!, page: 1)
        super.init()
    }
    
    func updateToken() {
        switch token {
        case .repositoryContributors(let repo, _):
            token = .repositoryContributors(repo: repo, page: page)
        case .organizationMembers(let org, _):
            token = .organizationMembers(org: org, page: page)
        case .followedBy(let user, _):
            token = .followedBy(user: user, page: page)
        case .followersOf(let user, _):
            token = .followersOf(user: user, page: page)
        default:
            break
        }
    }
    
    override func fetchData() {
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
                    if let newUsers = Mapper<User>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newUsers
                        } else {
                            self.dataSource.value.append(contentsOf: newUsers)
                        }
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    func userViewModelForIndex(_ index: Int) -> UserViewModel {
        return UserViewModel(dataSource.value[index])
    }
}
