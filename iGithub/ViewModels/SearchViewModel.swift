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
    
    enum SearchObject {
        case repository
        case user
    }
    
    let repoTVM = RepositoriesSearchViewModel()
    let userTVM = UsersSearchViewModel()
    
    var searchObject: SearchObject = .repository
    
    func search(query: String) {
        switch searchObject {
        case .repository:
            repoTVM.query = query
            repoTVM.refresh()
        case .user:
            userTVM.query = query
            userTVM.refresh()
        }
    }
    
    @objc func fetchNextPage() {
        switch searchObject {
        case .repository:
            repoTVM.fetchData()
        case .user:
            userTVM.fetchData()
        }
    }
    
    func clean() {
        repoTVM.dataSource.value = []
        userTVM.dataSource.value = []
    }
}

// MARK: SubViewModels

class RepositoriesSearchViewModel: BaseTableViewModel<Repository> {
    
    var query: String?
    var sort: RepositoriesSearchSort = .bestMatch
    var language = "All Languages"
    
    let sortOptions: [RepositoriesSearchSort] = [
        .bestMatch, .stars, .forks, .updated
    ]
    
    var token: GithubAPI {
        let lan = languagesDict[language]!
        let q = lan.characters.count > 0 ? query! + "+language:\(lan)" : query!
        
        return GithubAPI.searchRepositories(q: q, sort: sort, page: page)
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(onNext: { [unowned self] in
                if let results = Mapper<Repository>().mapArray(JSONObject: ($0 as! [String: Any])["items"]) {
                    if self.page == 1 {
                        self.dataSource.value = results
                    } else {
                        self.dataSource.value.append(contentsOf: results)
                    }
                    self.page += 1
                } else {
                    // deal with error
                }
            })
            .addDisposableTo(disposeBag)
    }
}

class UsersSearchViewModel: BaseTableViewModel<User> {
    
    var query: String?
    var sort: UsersSearchSort = .bestMatch
    
    let sortOptions: [UsersSearchSort] = [
        .bestMatch, .followers, .repositories, .joined
    ]
    
    var token: GithubAPI {
        return GithubAPI.searchUsers(q: query!, sort: sort, page: page)
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(onNext: { [unowned self] in
                if let results = Mapper<User>().mapArray(JSONObject: ($0 as! [String: Any])["items"]) {
                    if self.page == 1 {
                        self.dataSource.value = results
                    } else {
                        self.dataSource.value.append(contentsOf: results)
                    }
                    self.page += 1
                } else {
                    // deal with error
                }
            })
            .addDisposableTo(disposeBag)
    }
}
