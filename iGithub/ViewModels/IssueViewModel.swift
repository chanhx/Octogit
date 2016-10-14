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
    
    enum SectionType {
        case content
        case milestone
        case asignees
        case changes
        case timeline
    }

    var token: GithubAPI
    var repo: String
    var issue: Issue
    
    private var sectionTypes = [SectionType]()
    
    init(repo: String, issue: Issue) {
        self.repo = repo
        token = .issueComments(repo: repo, number: issue.number!)
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
        GithubProvider
            .request(token)
            .filterSuccessfulStatusCodes()
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
