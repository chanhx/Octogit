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
    
    var user: String
    
    init(user: User) {
        self.user = user.login!
        
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.userGists(user: user, page: page)
        
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
