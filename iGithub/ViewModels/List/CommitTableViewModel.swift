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
    var token: GithubAPI
    
    init(repo: String, branch: String) {
        self.repo = repo
        token = .repositoryCommits(repo: repo, sha: branch, page: 1)
        
        super.init()
    }
    
    init(repo: String, pullRequestNumber: Int) {
        self.repo = repo
        token = .pullRequestCommits(repo: repo, number: pullRequestNumber, page: 1)
        
        super.init()
    }
    
    func updateToken() {
        switch token {
        case .repositoryCommits(let repo, let branch, _):
            token = .repositoryCommits(repo: repo, sha: branch, page: page)
        case .pullRequestCommits(let repo, let number, _):
            token = .pullRequestCommits(repo: repo, number: number, page: page)
        default:
            break
        }
    }
    
    override func fetchData() {
        updateToken()
        
        GithubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newCommits = Mapper<Commit>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newCommits
                        } else {
                            self.dataSource.value.append(contentsOf: newCommits)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    func commitViewModel(forRow row: Int) -> CommitViewModel {
        let commit = dataSource.value[row]
        return CommitViewModel(repo: repo, commit: commit)
    }
}
