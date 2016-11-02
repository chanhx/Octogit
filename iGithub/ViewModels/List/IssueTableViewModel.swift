//
//  IssueTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class IssueTableViewModel: BaseTableViewModel<Issue> {
    
    private var repo: String
    var state: IssueState
    
    init(repo: String, state: IssueState = .open) {
        self.repo = repo
        self.state = state
        
        super.init()
    }
    
    override func fetchData() {
        let token = GithubAPI.repositoryIssues(repo: repo, page: page, state: state)
        
        GithubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newIssues = Mapper<Issue>().mapArray(JSONObject: $0) {
                        
                        let filteredIssues = newIssues.filter {
                            !$0.isPullRequest
                        }
                        
                        if self.page == 1 {
                            self.dataSource.value = filteredIssues
                        } else {
                            self.dataSource.value.append(contentsOf: filteredIssues)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func viewModelForIndex(_ index: Int) -> IssueViewModel {
        return IssueViewModel(repo: repo, issue: dataSource.value[index])
    }
}
