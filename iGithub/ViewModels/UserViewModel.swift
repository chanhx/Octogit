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
    case company
    case location
    case email
    case blog
}

class UserViewModel {
    
    var user: Variable<User>
    let disposeBag = DisposeBag()
    var token: GithubAPI
    
    var userLoaded = false
    var details = [VcardDetail]()
    
    init(_ user: User) {
        self.user = Variable(user)
        token = .user(user: user.login!)
    }

    init(_ username: String) {
        user = Variable(Mapper<User>().map(JSON: ["login": username])!)
        token = .user(user: username)
    }
    
    var title: String {
        return user.value.login!
    }
    
    func fetchUser() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(onNext: {
                self.userLoaded = true
                self.user.value = Mapper<User>().map(JSONObject: $0)!
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        guard userLoaded else {
            return 1
        }
        var sections = 2
        let u = user.value
        
        if u.company != nil {details.append(.company)}
        if u.location != nil {details.append(.location)}
        if u.email != nil {details.append(.email)}
        if u.blog != nil {details.append(.blog)}

        if details.count > 0 {sections += 1}
        
        return sections
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
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
