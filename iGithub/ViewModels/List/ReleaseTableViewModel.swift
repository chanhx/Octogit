//
//  ReleaseTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/6/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class ReleaseTableViewModel: BaseTableViewModel<Release> {
    
    var repo: String
    
    init(repo: Repository) {
        self.repo = repo.fullName!
        
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.releases(repo: repo, page: page)
        
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
                    let newReleases = Mapper<Release>().mapArray(JSONObject: $0)!
                    
                    self.dataSource.value.append(contentsOf: newReleases)
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .addDisposableTo(disposeBag)
    }
    
}
