//
//  PullRequestTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/2/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class PullRequestTableViewModel: BaseTableViewModel<PullRequest> {
    
    fileprivate var repo: String
    fileprivate var token: GithubAPI
    
    init(repo: Repository) {
        self.repo = repo.fullName!
        token = .repositoryPullRequests(repo: repo.fullName!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newPullRequests = Mapper<PullRequest>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newPullRequests)
                    }
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    func viewModelForIndex(_ index: Int) -> IssueViewModel {
        return IssueViewModel(repo: repo, issue: dataSource.value[index])
    }
}

