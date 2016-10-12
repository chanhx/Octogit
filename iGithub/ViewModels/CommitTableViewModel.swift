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
    
    var token: GithubAPI
    
    init(repo: Repository, branch: String? = nil) {
        token = .repositoryCommits(repo: repo.fullName!,
                                   branch: branch ?? repo.defaultBranch!,
                                   page: 1)
        
        super.init()
    }
    
    init(repo: String, pullRequestNumber: Int) {
        token = .pullRequestCommits(repo: repo,
                                    number: pullRequestNumber,
                                    page: 1)
        
        super.init()
    }
    
    func updateToken() {
        switch token {
        case .repositoryCommits(let repo, let branch, _):
            token = .repositoryCommits(repo: repo, branch: branch, page: page)
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
            .do(onNext: {
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newCommits = Mapper<Commit>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newCommits
                        } else {
                            self.dataSource.value.append(contentsOf: newCommits)
                        }
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
}
