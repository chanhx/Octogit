//
//  PullRequestFileTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class PullRequestFileTableViewModel: BaseTableViewModel<PullRequestFile> {
    
    var token: GithubAPI
    
    init(repo: String, pullRequestNumber: Int) {
        token = .pullRequestFiles(repo: repo, number: pullRequestNumber, page: 1)
        
        super.init()
    }
    
    override func fetchData() {

        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newFiles = Mapper<PullRequestFile>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newFiles)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
}
