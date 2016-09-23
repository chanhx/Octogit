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
    
//    var selectedIndexes = [0, 0]
    
}

protocol TrendingViewModelProtocol {
    var disposeBag: DisposeBag { get }
    var token: WebAPI { get }
    var since: TrendingTime? { get set }
    var language: String? { get set }
    func fetchHTML()
    func parse(_ doc: HTMLDocument)
}

extension TrendingViewModelProtocol {
    func fetchHTML() {
        WebProvider
            .request(token)
            .mapString()
            .subscribe(onNext: {
                guard let doc = Kanna.HTML(html: $0, encoding: String.Encoding.utf8) else {
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
    var repositories: Variable<[(name: String, description: String?, meta: String)]> = Variable([])
    var token: WebAPI {
        return WebAPI.trending(since: since!, language: languagesDict[language!]!, type: .repositories)
    }
    
    @inline(__always) func parse(_ doc: HTMLDocument) {
        repositories.value = doc.css("li.repo-list-item").map {
            let name = String($0.at_css("h3.repo-list-name a")!["href"]!.characters.dropFirst())
            
            let rawDesc = $0.at_css("p.repo-list-description")
            let description = rawDesc?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let meta = $0.at_css("p.repo-list-meta")!.text!.components(separatedBy: "•").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }.dropLast().joined(separator: " • ")
            
            return (name, description, meta)
        }
    }
}

class TrendingUserTableViewModel: TrendingViewModelProtocol {
    
    var disposeBag = DisposeBag()
    var since: TrendingTime?
    var language: String?
    var users: Variable<[User]> = Variable([])
    var token: WebAPI {
        return WebAPI.trending(since: since!, language: languagesDict[language!]!, type: .users)
    }
    
    @inline(__always) func parse(_ doc: HTMLDocument) {
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
