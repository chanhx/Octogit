//
//  PullRequestTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/2/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class PullRequestTableViewModel: BaseTableViewModel<PullRequest> {
    
    private var repo: String
    
    init(repo: Repository) {
        self.repo = repo.fullName!
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.repositoryPullRequests(repo: repo, page: page)
        
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

