//
//  IssueTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class IssueTableViewModel: BaseTableViewModel<Issue> {
    
    private var token: GithubAPI
    
    init(repo: Repository) {
        token = .RepositoryIssues(repo: repo.fullName!)
        super.init()
    }
    
    override func fetchData() {
        provider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newIssues = Mapper<Issue>().mapArray($0) {
                        self.dataSource.value.appendContentsOf(newIssues)
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
}
