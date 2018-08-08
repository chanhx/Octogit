//
//  ExplorationViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift
import RxMoya
import Kanna
import ObjectMapper
//import Result

let languagesArray: [String] = {
    let path = Bundle.main.path(forResource: "languages_array", ofType: "plist")
    return NSArray(contentsOfFile: path!) as! [String]
}()

let languagesDict: [String: String] = {
    let path = Bundle.main.path(forResource: "languages_dict", ofType: "plist")
    return NSDictionary(contentsOfFile: path!) as! [String: String]
}()

class ExplorationViewModel {
    
    var since: TrendingTime
    var language: String
    var type: TrendingType {
        didSet {
            updateOptions()
        }
    }

    let pickerVM = PickerViewModel()
    let repoTVM = TrendingRepositoryTableViewModel()
    let userTVM = TrendingUserTableViewModel()
    
    var timeOptions: [String] {
        get {
            return pickerVM.timeOptions.map {$0.desc}
        }
    }
    
    init(since: TrendingTime = .today, language: String = "All Languages", type: TrendingType = .repositories) {
        self.since = since
        self.language = language
        self.type = type
        
        updateOptions()
    }
    
    func updateOptions() {
        var trendingVM: TrendingViewModelProtocol
        switch type {
        case .repositories:
            trendingVM = repoTVM
        case .users:
            trendingVM = userTVM
        }
        
        guard trendingVM.since != since || trendingVM.language != language else {
            return
        }
        trendingVM.since = since
        trendingVM.language = language
        
        switch type {
        case .repositories:
            repoTVM.message = nil
            repoTVM.repositories.value.removeAll()
        case .users:
            userTVM.message = nil
            userTVM.users.value.removeAll()
        }
        
        trendingVM.fetchHTML()
    }
}

// MARK: SubViewModels

class PickerViewModel {
    
    let timeOptions: [(time: TrendingTime, desc: String)] = [
        (.today, "today"),
        (.thisWeek, "this week"),
        (.thisMonth, "this month")
    ]
    
}

protocol TrendingViewModelProtocol: class {
    var disposeBag: DisposeBag { get }
    var token: GitHubAPI { get }
    var since: TrendingTime? { get set }
    var language: String? { get set }
    func fetchHTML()
    func parse(_ doc: HTMLDocument)
}

extension TrendingViewModelProtocol {
    func fetchHTML() {
        GitHubProvider
            .request(token)
            .mapString()
            .subscribe(onSuccess: { [unowned self] (body: String) in
                guard let doc = try? Kanna.HTML(html: body, encoding: String.Encoding.utf8) else {
                    return  // Result(error: ParseError.HTMLParseError)
                }
                self.parse(doc)
            })
            .addDisposableTo(disposeBag)
    }
}

class TrendingRepositoryTableViewModel: TrendingViewModelProtocol {
    
    var disposeBag = DisposeBag()
    var since: TrendingTime?
    var language: String?
    var repositories: Variable<[(name: String, repoDescription: String?, language: String?, stargazers: String?, forks: String?, periodStargazers: String?)]>
        = Variable([])
    var message: String?
    var token: GitHubAPI {
        return GitHubAPI.trending(since: since!, language: languagesDict[language!]!, type: .repositories)
    }
    
    @inline(__always) func parse(_ doc: HTMLDocument) {
        message = doc.css("div.blankslate h3").first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        repositories.value = doc.css("div.explore-content li").map {
            let name = String($0.at_css("h3 a")!["href"]!.characters.dropFirst())
            
            let rawDesc = $0.at_css("div.py-1 p")
            let description = rawDesc?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let language = $0.at_css("span[itemprop=\"programmingLanguage\"]")?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let starSVG = $0.at_css("svg[aria-label=\"star\"]")
            let stargazers = starSVG?.parent?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let forkSVG = $0.at_css("svg[aria-label=\"fork\"]")
            let forks = forkSVG?.parent?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let periodStargazers = $0.at_css("span svg.octicon-star")?.parent?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return (name, description, language, stargazers, forks, periodStargazers)
        }
    }
}

class TrendingUserTableViewModel: TrendingViewModelProtocol {
    
    var disposeBag = DisposeBag()
    var since: TrendingTime?
    var language: String?
    var users: Variable<[User]> = Variable([])
    var message: String?
    var token: GitHubAPI {
        return GitHubAPI.trending(since: since!, language: languagesDict[language!]!, type: .users)
    }
    
    @inline(__always) func parse(_ doc: HTMLDocument) {
        message = doc.css("div.blankslate h3").first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        users.value = doc.css("li.user-leaderboard-list-item.leaderboard-list-item").map {
            let name = String($0.at_css("div h2 a")!["href"]!.characters.dropFirst())
            let avatarURL = $0.at_css("a img")!["src"]!

            var type: String
            switch $0.css("div.leaderboard-action span") {
            case .none:
                type = "Organization"
            default:
                type = "User"
            }
            
            return Mapper<User>().map(JSON: ["login": name, "avatar_url": avatarURL, "type": type])!
        }
    }
}
