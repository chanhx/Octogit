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
    var organizations: Variable<[User]> = Variable([])
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
                let user = Mapper<User>().map(JSONObject: $0)!
                self.setDetails(user: user)
                self.user.value = user
            })
            .addDisposableTo(disposeBag)
    }
    
    func fetchOrganizations() {
        GithubProvider
            .request(.organizations(user: user.value.login!))
            .mapJSON()
            .subscribe(onNext: {
                self.organizations.value = Mapper<User>().mapArray(JSONObject: $0)!
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        guard userLoaded else {
            return 1
        }

        return details.count > 0 ? 3 : 2
    }
    
    private func setDetails(user: User) {
        details.removeAll()
        
        if let company = user.company, company.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            details.append(.company)
        }
        if let location = user.location, location.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            details.append(.location)
        }
        if let email = user.email, email.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            details.append(.email)
        }
        if let blog = user.blog, blog.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            details.append(.blog)
        }
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
            return organizations.value.count
        default:
            return 0
        }
    }
}
