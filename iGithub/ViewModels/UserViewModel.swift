//
//  UserViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxMoya
import RxSwift
import ObjectMapper

class UserViewModel: NSObject {
    
    var user: Variable<User>
    var provider = RxMoyaProvider<GithubAPI>()
    var disposeBag = DisposeBag()
    var token: GithubAPI
    
    var userLoaded = false
    var detailsRowsCount = 0
    
    init(user: User) {
        self.user = Variable(user)
        token = .User(username: user.login!)
        super.init()
    }

    init(username: String) {
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
        
        if u.company != nil {detailsRowsCount += 1}
        if u.blog != nil {detailsRowsCount += 1}
        if u.email != nil {detailsRowsCount += 1}
        if u.location != nil {detailsRowsCount += 1}

        if detailsRowsCount > 0 {sections += 1}
        
        return sections
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        guard userLoaded else {
            return 1
        }
        
        switch section {
        case 0:
            return detailsRowsCount > 0 ? detailsRowsCount : 3
        case 1:
            return detailsRowsCount > 0 ? 3 : 1
        default:
            return 1
        }
    }
}
