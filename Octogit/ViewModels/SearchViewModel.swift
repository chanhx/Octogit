//
//  SearchViewModel.swift
//  Octogit
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
            repoTVM.isLoading = true
            repoTVM.dataSource.value.removeAll()
            repoTVM.refresh()
        case .user:
            userTVM.query = query
            userTVM.isLoading = true
            userTVM.dataSource.value.removeAll()
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
        repoTVM.query = nil
        userTVM.query = nil
        
        repoTVM.dataSource.value = []
        userTVM.dataSource.value = []
    }
}

// MARK: SubViewModels

class RepositoriesSearchViewModel: BaseTableViewModel<Repository> {
    
    var query: String?
    var sort: RepositoriesSearchSort = .bestMatch
    var language = "All Languages"
    var isLoading = false
    
    let sortOptions: [RepositoriesSearchSort] = [
        .bestMatch, .stars, .forks, .updated
    ]
    
    var token: GitHubAPI {
        
        var q = query!
        
        switch sort {
        case .stars:
            q += " sort:stars"
        case .forks:
            q += " sort:forks"
        case .updated:
            q += " sort:updated"
        default:
            break
        }
        
        let lan = languagesDict[language]!
        if lan.count > 0 {
            q += " language:\(lan)"
        }
        
        return GitHubAPI.searchRepositories(query: q, after: endCursor)
    }
    
    override func fetchData() {
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { [unowned self] in
                
                guard
                    let json = ($0 as? [String: [String: Any]])?["data"]?["search"],
                    let connection = Mapper<EntityConnection<Repository>>().map(JSONObject: json),
                    let newRepos = connection.nodes
                else {
                    // deal with error
                    return
                }
                
                self.hasNextPage = connection.pageInfo!.hasNextPage!
                
                if self.endCursor == nil {
                    self.dataSource.value = newRepos
                } else {
                    self.dataSource.value.append(contentsOf: newRepos)
                }
                
                self.endCursor = connection.pageInfo?.endCursor
            })
            .disposed(by: disposeBag)
    }
}

class UsersSearchViewModel: BaseTableViewModel<User> {
    
    var query: String?
    var sort: UsersSearchSort = .bestMatch
    var isLoading = false
    
    let sortOptions: [UsersSearchSort] = [
        .bestMatch, .followers, .repositories, .joined
    ]
    
    var token: GitHubAPI {
        return GitHubAPI.searchUsers(q: query!, sort: sort, page: page)
    }
    
    override func fetchData() {        
        GitHubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                self.isLoading = false
                
                if let headers = $0.response?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(onSuccess: { [unowned self] in
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
            .disposed(by: disposeBag)
    }
}
