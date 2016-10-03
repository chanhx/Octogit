//
//  CommitTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class CommitTableViewModel: BaseTableViewModel<Commit> {
    
    fileprivate var token: GithubAPI
    
    init(repo: Repository, branch: String? = nil) {
        token = .repositoryCommits(repo: repo.fullName!, branch: branch ?? repo.defaultBranch!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newCommits = Mapper<Commit>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newCommits)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
}
