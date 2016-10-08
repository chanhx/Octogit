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
    
    var repo: String
    var branch: String
    
    init(repo: Repository, branch: String? = nil) {
        self.repo = repo.fullName!
        self.branch = branch ?? repo.defaultBranch!
        
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.repositoryCommits(repo: repo, branch: branch, page: page)
        
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
