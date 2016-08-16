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

class ExplorationViewModel {
    
    let provider = RxMoyaProvider<WebAPI>()
    let disposeBag = DisposeBag()
    
    var token: WebAPI!
    var since: TrendingTime
    var language: String
    var type: SegmentTitle {
        didSet {
            updateOptions()
        }
    }

    let repoTVM = TrendingRepositoryTableViewModel()
    let userTVM = TrendingUserTableViewModel()
    
    init(since: TrendingTime = .Today, language: String = "", type: SegmentTitle = .Repositories) {
        self.since = since
        self.language = language
        self.type = type
        
        updateOptions()
    }
    
    func updateOptions() {
        token = WebAPI.Trending(since: since, language: language, type: type)
        
        var trendingVM: TrendingViewModelProtocol
        switch type {
        case .Repositories:
            trendingVM = repoTVM
        case .Users:
            trendingVM = userTVM
        }
        
        guard trendingVM.since != since && trendingVM.language != language else {
            return
        }
        trendingVM.since = since
        trendingVM.language = language
        fetchHTML()
    }
    
    func fetchHTML() {
        provider
            .request(token)
            .mapString()
            .subscribeNext {
                guard let doc = Kanna.HTML(html: $0, encoding: NSUTF8StringEncoding) else {
                    return// Result(error: ParseError.HTMLParseError)
                }
                
                switch self.type {
                case .Repositories:
                    self.repoTVM.parse(doc)
                case .Users:
                    self.userTVM.parse(doc)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: SubViewModels

protocol TrendingViewModelProtocol {
    var since: TrendingTime? { get set }
    var language: String? { get set }
    func parse(doc: HTMLDocument)
}

class TrendingRepositoryTableViewModel: TrendingViewModelProtocol {
    
    var since: TrendingTime?
    var language: String?
    var repositories: Variable<[(name: String, description: String?, meta: String)]> = Variable([])
    
    @inline(__always) func parse(doc: HTMLDocument) {
        repositories.value = doc.css("li.repo-list-item").map {
            let name = String($0.css("h3.repo-list-name a")[0]["href"]!.characters.dropFirst())
            
            var description: String?
            if let rawDesc = $0.css("p.repo-list-description").first {
                description = rawDesc.text!.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            }
            
            let meta = $0.css("p.repo-list-meta")[0].text!.componentsSeparatedByString("•").map {
                $0.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
                }.dropLast().joinWithSeparator(" • ")
            
            return (name, description, meta)
        }
    }
}

class TrendingUserTableViewModel: TrendingViewModelProtocol {
    
    var since: TrendingTime?
    var language: String?
    var users: Variable<[User]> = Variable([])
    
    @inline(__always) func parse(doc: HTMLDocument) {
        users.value = doc.css("li.user-leaderboard-list-item.leaderboard-list-item").map {
            let name = String($0.css("div h2 a")[0]["href"]!.characters.dropFirst())
            let avatarURL = $0.css("a img")[0]["src"]!
            
            return Mapper<User>().map(["login": name, "avatar_url": avatarURL])!
        }
    }
}