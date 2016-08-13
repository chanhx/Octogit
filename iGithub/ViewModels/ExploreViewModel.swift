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
//import Result

class ExplorationViewModel {
    
    let provider = RxMoyaProvider<WebAPI>()
    let disposeBag = DisposeBag()
    
    let token = WebAPI.Trending(since: .Today, language: "", typeRepo: true)
    
    let repoTVM = TrendingRepositoryTableViewModel()
    let userTVM = TrendingUserTableViewModel()
    
    func fetchHTML() {
        provider
            .request(token)
            .mapString()
            .subscribeNext {
                guard let doc = Kanna.HTML(html: $0, encoding: NSUTF8StringEncoding) else {
                    return// Result(error: ParseError.HTMLParseError)
                }
                
                self.repoTVM.parseRepositories(doc)
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: SubViewModels

class TrendingRepositoryTableViewModel {
    var repositories: Variable<[(name: String, description: String?, meta: String)]> = Variable([])
    
    @inline(__always) func parseRepositories(doc: HTMLDocument) {
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

class TrendingUserTableViewModel {
    
}