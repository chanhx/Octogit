//
//  PullRequestViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/09/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import Foundation
import Mustache
import RxSwift
import ObjectMapper

class PullRequestViewModel: BaseTableViewModel<Comment> {
    
    var repo: String
    var pullRequest: PullRequest!
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
        
        token = .pullRequest(owner: owner, name: name, number: number)
        
        super.init()
        
        fetchContent()
    }
    
    init(repo: String, pullRequest: PullRequest) {
        self.number = pullRequest.number
        self.repo = repo
        self.pullRequest = pullRequest
        
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
                    
                    guard let pullRequest = Mapper<PullRequest>().map(JSONObject: $0) else {
                        return
                    }
                    
                    self.pullRequest = pullRequest
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
        guard let _ = pullRequest else {
            return
        }
        
        let token: GitHubAPI = .issueComments(repo: repo, number: pullRequest.number!, page: page)
        
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
            "title": pullRequest.title!,
            "created_at": pullRequest.createdAt!.naturalString(),
            "repository": self.repo,
            "author": pullRequest.author!.login!,
            "avatar_url": pullRequest.author!.avatarURL!,
            "pullRequest_number": pullRequest.number,
            "comments": self.dataSource.value.map {
                [
                    "author": "\($0.user!)",
                    "avatar_url": $0.user!.avatarURL?.absoluteString ?? "",
                    "content": $0.body ?? "",
                    "created_at": $0.createdAt!.naturalString(),
                    ]
            },
        ]
        
        if let state = pullRequest.state {
            var status: String
            switch state {
            case .closed:
                if let _  = pullRequest.mergedAt {
                    status = "merged"
                } else {
                    status = "closed"
                }
            case .open:
                status = "open"
            }
            data["state"] = try! Template(named: "pullRequest-\(status)-span")
        }
        
        if let body = pullRequest.bodyHTML, body.count > 0 {
            data["content"] = body
        }
        
        if let milestone = pullRequest.milestone?.title {
            data["milestone"] = milestone
        }
        
        if let labels = pullRequest.labels {
            
            data["labels"] = labels.map {
                [
                    "name": $0.name!,
                    "color": $0.color!
                ]
            }
        }
        
        if let assignees = pullRequest.assignees, assignees.count > 0 {
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
