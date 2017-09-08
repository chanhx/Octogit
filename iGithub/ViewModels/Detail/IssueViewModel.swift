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

class IssueViewModel: BaseTableViewModel<Comment> {
    
    var repo: String
    var issue: Issue
    
    init(repo: String, issue: Issue) {
        self.repo = repo
        self.issue = issue
        
        super.init()
    }
    
    override func fetchData() {
        let token: GitHubAPI = issue.isPullRequest ?
            .pullRequestComments(repo: repo, number: issue.number!, page: page) :
            .issueComments(repo: repo, number: issue.number!, page: page)
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(
                onNext: { [unowned self] in
                    if let newComments = Mapper<Comment>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newComments)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    var contentHTML: String {
        let template = try! Template(named: "issue")
        template.register(StandardLibrary.each, forKey: "each")
        
        return try! template.render(Box(templateData))
    }
    
    var templateData: [String : Any] {
        
        var data: [String : Any] = [
            "title": issue.title!,
            "created_at": issue.createdAt!.naturalString(),
            "repository": self.repo,
            "author": issue.user!.login!,
            "avatar_url": issue.user!.avatarURL!,
            "comments": self.dataSource.value.map {
                [
                    "author": "\($0.user!)",
                    "avatar_url": $0.user!.avatarURL?.absoluteString ?? "",
                    "content": $0.body ?? "",
                    "created_at": $0.createdAt!.naturalString(),
                ]
            },
        ]
        
        if let state = issue.state {
            if issue.isPullRequest {
                var status: String
                switch state {
                case .closed:
                    if let _  = (issue as? PullRequest)?.mergedAt {
						status = "merged"
                    } else {
						status = "closed"
                    }
                case .open:
					status = "open"
                }
                data["state"] = try! Template(named: "pulls-\(status)")
            } else {
                data["state"] = try! Template(named: "issue-\(state.rawValue)")
            }
        }
        
        if let body = issue.body {
            data["content"] = body.characters.count > 0 ? body : "<p>No discription given.</p>"
        }
        
        if let milestone = issue.milestone?.title {
            data["milestone"] = milestone
        }
        
        if let labels = issue.labels {
            
            data["labels"] = labels.map {
                [
                    "name": $0.name!,
                    "color": $0.color!
                ]
            }
        }
        
        if let assignees = issue.assignees, assignees.count > 0 {
            data["asignees"] = assignees.map {
                [
                    "asignee": $0.login,
                    "avatar_url": $0.avatarURL!,
                ]
            }
        }
        
        return data
    }
}
