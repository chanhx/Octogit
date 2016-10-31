//
//  GistTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/4/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class GistTableViewModel: BaseTableViewModel<Gist> {
    
    var token: GithubAPI
    
    override init() {
        token = .starredGists(page: 1)
        
        super.init()
    }
    
    init(user: String) {
        token = .userGists(user: user, page: 1)
        
        super.init()
    }
    
    func updateToken() {
        switch token {
        case .starredGists:
            token = .starredGists(page: page)
        case .userGists(let user, _):
            token = .userGists(user: user, page: page)
        default:
            break
        }
    }
    
    override func fetchData() {
        updateToken()
        
        GithubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newGists = Mapper<Gist>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newGists
                        } else {
                            self.dataSource.value.append(contentsOf: newGists)
                        }
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .addDisposableTo(disposeBag)
    }
    
}
