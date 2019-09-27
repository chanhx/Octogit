//
//  IssueViewModel.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Mustache
import RxSwift
import ObjectMapper

class IssueViewModel: BaseTableViewModel<Comment> {
    
    var repo: String
    var issue: Issue!
    var number: Int
    var token: GitHubAPI?
    
    let template: Template = {
        let template = try! Template(named: "issue")
        template.register(StandardLibrary.each, forKey: "each")
        
        return template
    }()
    var html = Variable<String?>(nil)
    
    init(owner: String, name: String, number: Int) {
        self.repo = "\(owner)/\(name)"
        self.number = number
        
        token = .issue(owner: owner, name: name, number: number)
        
        super.init()
        
        fetchContent()
    }
    
    init(repo: String, issue: Issue) {
        self.number = issue.number
        self.repo = repo
        self.issue = issue
        
        super.init()
        
        html.value = try? template.render(Box(templateData))
    }
    
    func fetchContent() {
        
        guard let token = self.token else {
            return
        }
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    
                    guard let issue = Mapper<Issue>().map(JSONObject: $0) else {
                        return
                    }
                    
                    self.issue = issue
                    self.fetchData()
                    self.html.value = try? self.template.render(Box(self.templateData))
                },
                onError: {
                    MessageManager.show(error: $0)
            }
            )
            .disposed(by: disposeBag)
    }
    
    override func fetchData() {
        guard let _ = issue else {
            return
        }
        
        let token: GitHubAPI = .issueComments(repo: repo, number: issue.number!, page: page)
        
        GitHubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    guard
                        let newComments = Mapper<Comment>().mapArray(JSONObject: $0),
                        newComments.count > 0
                    else {
                        return
                    }
                    
                    self.dataSource.value.append(contentsOf: newComments)
                    self.html.value = try? self.template.render(Box(self.templateData))
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .disposed(by: disposeBag)
    }
    
    var templateData: [String : Any] {
        
        var data: [String : Any] = [
            "title": issue.title!,
            "created_at": issue.createdAt!.naturalString(),
            "repository": self.repo,
            "author": issue.author!.login!,
            "avatar_url": issue.author!.avatarURL!,
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
            data["state"] = try! Template(named: "issue-\(state.rawValue)-span")
        }
        
        if let body = issue.bodyHTML, body.count > 0 {
            data["content"] = body
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
