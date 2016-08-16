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
    
    var query: String?
    var type: SegmentTitle {
        didSet {
            if query != nil && query?.characters.count > 0 {
                search(query!)
            }
        }
    }
    
    func search(query: String) {
        self.query = query
        switch type {
        case .Repositories:
            if query != repoTVM.query {
                repoTVM.search(query)
            }
        case .Users:
            if query != userTVM.query {
                userTVM.search(query)
            }
        }
    }
    
    init(query: String? = nil, type: SegmentTitle = .Repositories) {
        self.query = query
        self.type = type
    }
}

// MARK: SubViewModels

class RepositoriesSearchViewModel {
    
    var query: String?
    var repositories: Variable<[Repository]> = Variable([])
    
    let disposeBag = DisposeBag()
    
    func search(query: String) {
        let token = GithubAPI.SearchRepositories(q: query, sort: .Default, order: .Desc)
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribeNext {
                if let results = Mapper<Repository>().mapArray($0["items"]) {
                    self.repositories.value = results
                    self.query = query
                } else {
                    // deal with error
                }
            }
            .addDisposableTo(disposeBag)
    }
}

class UsersSearchViewModel {
    
    var query: String?
    var users: Variable<[User]> = Variable([])
    
    let disposeBag = DisposeBag()
    
    func search(query: String) {
        let token = GithubAPI.SearchUsers(q: query, sort: .Default, order: .Desc)
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribeNext {
                if let results = Mapper<User>().mapArray($0["items"]) {
                    self.users.value = results
                    self.query = query
                } else {
                    // deal with error
                }
            }
            .addDisposableTo(disposeBag)
    }
}
