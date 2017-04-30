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
    
    enum SectionType {
        case content
        case milestone
        case asignees
        case changes
        case timeline
    }

    var repo: String
    var issue: Issue
    
    private var sectionTypes = [SectionType]()
    
    init(repo: String, issue: Issue) {
        self.repo = repo
        self.issue = issue
        
        super.init()
        
        setSectionTypes()
    }
    
    func setSectionTypes() {
        if let body = issue.body,
            body.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            sectionTypes.append(.content)
        }
        
        if let _ = issue.milestone {
            sectionTypes.append(.milestone)
        }
        
        if let assignees = issue.assignees, assignees.count > 0 {
            sectionTypes.append(.asignees)
        }
        
        if let _ = issue as? PullRequest {
            sectionTypes.append(.changes)
        }
        
        sectionTypes.append(.timeline)
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
    
    var numberOfSections: Int {
        return sectionTypes.count
    }
    
    func sectionType(for section: Int) -> SectionType {
        return sectionTypes[section]
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        switch sectionTypes[section] {
        case .content:
            return 1
        case .milestone:
            return 1
        case .asignees:
            return issue.assignees!.count
        case .changes:
            return 2
        case .timeline:
            return dataSource.value.count
        }
    }
    
    var contentHTML: String {
        let template = try! Template(named: "issue")
        
        let data = ["content": issue.body!]
        
        return try! template.render(Box(data))
    }
}
