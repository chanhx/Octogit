//
//  IssueViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import WebKit
import Mustache
import RxSwift
import ObjectMapper

class IssueViewModel: BaseTableViewModel<IssueComment> {
    
    enum ContentType {
        case body
        case label
        case milestone
    }

    var token: GithubAPI
    var issue: Issue
    
    var contentTypes = [ContentType]()
    
    init(repo: String, issue: Issue) {
        token = .issueComments(repo: repo, number: issue.number!)
        self.issue = issue
        
        if let count = issue.body?.characters.count, count > 0 {
            contentTypes.append(.body)
        }
        if let count = issue.labels?.count, count > 0 {
            contentTypes.append(.label)
        }
        if issue.milestone != nil {
            contentTypes.append(.milestone)
        }
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let newComments = Mapper<IssueComment>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newComments)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        if let count = issue.assignees?.count, count > 0 {
            return contentTypes.count > 0 ? 2 : 1
        } else {
            return contentTypes.count > 0 ? 1 : 0
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            if contentTypes.count > 0 {
                return contentTypes.count
            } else {
                return issue.assignees!.count
            }
        case 1:
            return issue.assignees!.count
        default:
            return 0
        }
    }
    
    var contentHTML: String {
        let template = try! Template(named: "issue")
        
        let data = ["content": issue.body!]
        
        return try! template.render(Box(data))
    }
}
