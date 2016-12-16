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

class UserViewModel {
    
    enum SectionType {
        case vcards
        case general
        case organizations
    }
    
    enum VcardDetail {
        case company
        case location
        case email
        case blog
    }
    
    var user: Variable<User>
    var isFollowing = Variable<Bool?>(nil)
    var organizations: Variable<[User]> = Variable([])
    let disposeBag = DisposeBag()
    var token: GithubAPI
    
    var userLoaded: Bool {
        return self.user.value.followers != nil
    }
    var sectionTypes = [SectionType]()
    var vcardDetails = [VcardDetail]()
    lazy var information: String = {
        var information: String = self.user.value.login!
        if let name = self.user.value.name, name.characters.count > 0 {
            information.append("(\(name))")
        }
        if let company = self.user.value.company, company.characters.count > 0 {
            information.append(", \(company)")
        }
        if let location = self.user.value.location, location.characters.count > 0 {
            information.append(", \(location)")
        }
        
        return information
    }()
    lazy var htmlURL: URL = {
        return URL(string: "https://github.com/\(self.user.value.login!)")!
    }()
    
    init(_ user: User) {
        self.user = Variable(user)
        token = .user(user: user.login!)
        
        if userLoaded {
            setSectionTypes(user: user)
        }
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
            .subscribe(onNext: { [unowned self] in
                let user = Mapper<User>().map(JSONObject: $0)!
                self.setSectionTypes(user: user)
                self.user.value = user
            })
            .addDisposableTo(disposeBag)
    }
    
    func fetchOrganizations() {
        GithubProvider
            .request(.organizations(user: user.value.login!))
            .mapJSON()
            .subscribe(onNext: { [unowned self] in
                self.organizations.value = Mapper<User>().mapArray(JSONObject: $0)!
            })
            .addDisposableTo(disposeBag)
    }
    
    func checkIsFollowing() {
        GithubProvider
            .request(.isFollowing(user: user.value.login!))
            .subscribe(onNext: { [unowned self] response in
                if response.statusCode == 204 {
                    self.isFollowing.value = true
                } else if response.statusCode == 404 {
                    self.isFollowing.value = false
                } else {
                    // error happened
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func toggleFollowing() {
        let token: GithubAPI = isFollowing.value! ? .unfollow(user: user.value.login!) : .follow(user: user.value.login!)
        
        GithubProvider
            .request(token)
            .subscribe(onNext: { [unowned self] response in
                if response.statusCode == 204 {
                    self.isFollowing.value = !self.isFollowing.value!
                } else {
                    let json = try! response.mapJSON()
                    print(json)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        return userLoaded ? sectionTypes.count : 1
    }
    
    private func setSectionTypes(user: User) {
        sectionTypes.removeAll()
        
        setVcardDetails(user: user)
        
        if vcardDetails.count > 0 {
            sectionTypes.append(.vcards)
        }
        
        sectionTypes.append(.general)
        
        if user.type! == .user {
            sectionTypes.append(.organizations)
        }
    }
    
    private func setVcardDetails(user: User) {
        vcardDetails.removeAll()
        
        if let company = user.company, company.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            vcardDetails.append(.company)
        }
        if let location = user.location, location.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            vcardDetails.append(.location)
        }
        if let email = user.email, email.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            vcardDetails.append(.email)
        }
        if let blog = user.blog, blog.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            vcardDetails.append(.blog)
        }
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        guard userLoaded else {
            return 1
        }
        
        switch sectionTypes[section] {
        case .vcards:
            return vcardDetails.count
        case .general:
            return 3
        case .organizations:
            return organizations.value.count
        }
    }
}
