//
//  UserViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxMoya
import RxSwift
import ObjectMapper

enum VcardDetail {
    case Company
    case Location
    case Email
    case Blog
}

class UserViewModel: NSObject {
    
    var user: Variable<User>
    let provider = RxMoyaProvider<GithubAPI>()
    let disposeBag = DisposeBag()
    var token: GithubAPI
    
    var userLoaded = false
    var details = [VcardDetail]()
    
    init(_ user: User) {
        self.user = Variable(user)
        token = .User(username: user.login!)
        super.init()
    }

    init(_ username: String) {
        user = Variable(Mapper<User>().map(["login": username])!)
        token = .User(username: username)
        super.init()
    }
    
    var title: String {
        return user.value.login!
    }
    
    func fetchUser() {
        provider
            .request(token)
            .mapJSON()
            .subscribeNext {
                self.userLoaded = true
                self.user.value = Mapper<User>().map($0)!
            }
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        guard userLoaded else {
            return 1
        }
        var sections = 2
        let u = user.value
        
        if u.company != nil {details.append(.Company)}
        if u.location != nil {details.append(.Location)}
        if u.email != nil {details.append(.Email)}
        if u.blog != nil {details.append(.Blog)}

        if details.count > 0 {sections += 1}
        
        return sections
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        guard userLoaded else {
            return 1
        }
        
        switch (section, details.count) {
        case (0, 1...4):
            return details.count
        case (0, 0), (1, 1...4):
            return 3
        case (1, 0), (2, _):
            return 1
        default:
            return 0
        }
    }
}
