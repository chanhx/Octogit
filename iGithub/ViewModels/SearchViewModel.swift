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
    case Repositories(sort: RepositoriesSearchSort, language: String)
    case Users(sort: UsersSearchSort)
}

func ==(lhs: SearchOption, rhs: SearchOption) -> Bool {
    switch (lhs, rhs) {
    case (.Repositories(let sortL, let languageL), .Repositories(let sortR, let languageR)):
        return sortL == sortR && languageL == languageR
    case (.Users(let sortL), .Users(let sortR)):
        return sortL == sortR
    case (.Repositories(_, _), _): return false
    case (.Users(_), _): return false
    }
}

class SearchViewModel {
    
    let repoTVM = RepositoriesSearchViewModel()
    let userTVM = UsersSearchViewModel()
    let titleVM = TitleViewModel()
    
    var query: String?
    var option: SearchOption {
        didSet {
            switch option {
            case .Repositories:
                options[0] = option
            case .Users:
                options[1] = option
            }
        }
    }
    var options: [SearchOption] = [
        .Repositories(sort: .Default, language: "All Languages"),
        .Users(sort: .Default)
    ]
    
    let reposSortOptions: [(option: RepositoriesSearchSort, desc: String)] = [
        (.Default, "Best match"),
        (.Stars, "Most stars"),
        (.Forks, "Most forks"),
        (.Updated, "Recently updated")
    ]
    
    let usersSortOptions: [(option: UsersSearchSort, desc: String)] = [
        (.Default, "Best match"),
        (.Followers, "Most followers"),
        (.Repositories, "Most repositories"),
        (.Joined, "Recently joined")
    ]
    
    func search(query: String) {
        self.query = query
        switch option {
        case .Repositories(let sort, let language):
            if query == repoTVM.query && option == options[0] {return}

            let lan = languagesDict[language]!
            let q = lan.characters.count > 0 ? query.stringByAppendingString("+language:\(languagesDict[lan])") : query
            let token = GithubAPI.SearchRepositories(q: q, sort: sort)
            repoTVM.search(query, token: token)
        case .Users(let sort):
            if query == userTVM.query && option == options[1] {return}
            
            let token = GithubAPI.SearchUsers(q: query, sort: sort)
            userTVM.search(query, token: token)
        }
    }
    
    init() {
        self.option = options[0]
    }
}

// MARK: SubViewModels

class TitleViewModel {
    func sortDescription(option: SearchOption) -> String {
        switch option {
        case .Repositories(let sort, _):
            switch sort {
            case .Default:
                return "Best match"
            case .Forks:
                return "Most forks"
            case .Stars:
                return "Most stars"
            case .Updated:
                return "Recently updated"
            }
        case .Users(let sort):
            switch sort {
            case .Default:
                return "Best match"
            case .Followers:
                return "Most followers"
            case .Repositories:
                return "Most repositories"
            case .Joined:
                return "Recently joined"
            }
        }
    }
}

class RepositoriesSearchViewModel {
    
    var query: String?
    var repositories: Variable<[Repository]> = Variable([])
    
    let disposeBag = DisposeBag()
    
    func search(query: String, token: GithubAPI) {
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
    
    func search(query: String, token: GithubAPI) {
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
