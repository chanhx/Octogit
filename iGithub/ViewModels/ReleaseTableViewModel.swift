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
    
    var token: GithubAPI
    
    init(repo: Repository) {
        token = .repositoryReleases(repo: repo.fullName!)
        
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    let newReleases = Mapper<Release>().mapArray(JSONObject: $0)!
                    
                    self.dataSource.value.append(contentsOf: newReleases)
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
}
