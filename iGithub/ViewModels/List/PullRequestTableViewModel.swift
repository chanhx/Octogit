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
    var state: IssueState
    
    init(repo: String, state: IssueState = .open) {
        self.repo = repo
        self.state = state
        
        super.init()
    }
    
    override func fetchData() {
        let token = GitHubAPI.pullRequests(repo: repo, page: page, state: state)
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .do(onNext: { [unowned self] in
                if let headers = $0.response?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    if let newPullRequests = Mapper<PullRequest>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newPullRequests
                        } else {
                            self.dataSource.value.append(contentsOf: newPullRequests)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
            })
            .disposed(by: disposeBag)
    }
    
    func viewModelForIndex(_ index: Int) -> PullRequestViewModel {
        return PullRequestViewModel(repo: repo, pullRequest: dataSource.value[index])
    }
}

