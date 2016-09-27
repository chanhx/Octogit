//
//  IssueTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import ObjectMapper

class IssueTableViewModel: BaseTableViewModel<Issue> {
    
    fileprivate var repo: String
    fileprivate var token: GithubAPI
    
    init(repo: Repository) {
        self.repo = repo.fullName!
        token = .repositoryIssues(repo: repo.fullName!)
        super.init()
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newIssues = Mapper<Issue>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newIssues)
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
