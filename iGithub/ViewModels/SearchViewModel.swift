//
//  SearchViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/16/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift
import RxMoya
import ObjectMapper

class SearchViewModel {
    
    let repoTVM = RepositoriesSearchViewModel()
    let userTVM = UsersSearchViewModel()
    
    let provider = RxMoyaProvider<GithubAPI>()
    let disposeBag = DisposeBag()
    
    var query: String
    var type: SegmentTitle {
        didSet {
            switch type {
            case .Repositories:
                if query != repoTVM.query {
                    search(query)
                }
            case .Users:
                if query != userTVM.query {
                    search(query)
                }
            }
        }
    }
    
    init(query: String = "", type: SegmentTitle = .Repositories) {
        self.query = query
        self.type = type
    }
    
    func search(query: String) {
        var token: GithubAPI
        switch type {
        case .Repositories:
            token = .SearchRepositories(q: query, sort: .Default, order: .Desc)
        case .Users:
            token = .SearchUsers(q: query, sort: .Default, order: .Desc)
        }
        
        self.query = query
        
        provider
            .request(token)
            .mapJSON()
            .subscribeNext {
                switch self.type {
                case .Repositories:
                    if let results = Mapper<Repository>().mapArray($0["items"]) {
                        self.repoTVM.repositories.value = results
                        self.repoTVM.query = query
                    } else {
                        // deal with error
                    }
                case .Users:
                    if let results = Mapper<User>().mapArray($0["items"]) {
                        self.userTVM.users.value = results
                        self.userTVM.query = query
                    } else {
                        // deal with error
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: SubViewModels

class RepositoriesSearchViewModel {
    var query: String?
    var repositories: Variable<[Repository]> = Variable([])
}

class UsersSearchViewModel {
    var query: String?
    var users: Variable<[User]> = Variable([])
}