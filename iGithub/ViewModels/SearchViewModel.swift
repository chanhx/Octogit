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

enum SearchOption {
    case repositories(sort: RepositoriesSearchSort, language: String)
    case users(sort: UsersSearchSort)
}

class SearchViewModel {
    
    let repoTVM = RepositoriesSearchViewModel()
    let userTVM = UsersSearchViewModel()
    let titleVM = TitleViewModel()
    
    var query: String?
    var option: SearchOption {
        didSet {
            switch option {
            case .repositories:
                options[0] = option
            case .users:
                options[1] = option
            }
        }
    }
    var options: [SearchOption] = [
        .repositories(sort: .bestMatch, language: "All Languages"),
        .users(sort: .bestMatch)
    ]
    
    let reposSortOptions: [(option: RepositoriesSearchSort, desc: String)] = [
        (.bestMatch, "Best match"),
        (.stars, "Most stars"),
        (.forks, "Most forks"),
        (.updated, "Recently updated")
    ]
    
    let usersSortOptions: [(option: UsersSearchSort, desc: String)] = [
        (.bestMatch, "Best match"),
        (.followers, "Most followers"),
        (.repositories, "Most repositories"),
        (.joined, "Recently joined")
    ]
    
    func search(_ query: String) {
        self.query = query
        switch option {
        case .repositories(let sort, let language):
            let lan = languagesDict[language]!
            let q = lan.characters.count > 0 ? query + "+language:\(lan)" : query
            let token = GithubAPI.searchRepositories(q: q, sort: sort)
            repoTVM.search(query, token: token)
        case .users(let sort):
            let token = GithubAPI.searchUsers(q: query, sort: sort)
            userTVM.search(query, token: token)
        }
    }
    
    init() {
        self.option = options[0]
    }
}

// MARK: SubViewModels

class TitleViewModel {
    func sortDescription(_ option: SearchOption) -> String {
        switch option {
        case .repositories(let sort, _):
            switch sort {
            case .bestMatch:
                return "Best match"
            case .forks:
                return "Most forks"
            case .stars:
                return "Most stars"
            case .updated:
                return "Recently updated"
            }
        case .users(let sort):
            switch sort {
            case .bestMatch:
                return "Best match"
            case .followers:
                return "Most followers"
            case .repositories:
                return "Most repositories"
            case .joined:
                return "Recently joined"
            }
        }
    }
}

class RepositoriesSearchViewModel {
    
    var query: String?
    var repositories: Variable<[Repository]> = Variable([])
    
    let disposeBag = DisposeBag()
    
    func search(_ query: String, token: GithubAPI) {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribeNext {
                if let results = Mapper<Repository>().mapArray(JSONObject: ($0 as! [String: Any])["items"]) {
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
    
    func search(_ query: String, token: GithubAPI) {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribeNext {
                if let results = Mapper<User>().mapArray(JSONObject: ($0 as! [String: Any])["items"]) {
                    self.users.value = results
                    self.query = query
                } else {
                    // deal with error
                }
            }
            .addDisposableTo(disposeBag)
    }
}
