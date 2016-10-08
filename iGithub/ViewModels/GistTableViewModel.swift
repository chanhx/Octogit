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
    
    init(user: User) {
        token = .userGists(user: user.login!, page: 1)
        
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .do(onNext: {
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: {                    
                    let newGists = Mapper<Gist>().mapArray(JSONObject: $0)!
                    
                    self.dataSource.value.append(contentsOf: newGists)
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
}
