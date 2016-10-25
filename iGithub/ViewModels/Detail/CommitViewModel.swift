//
//  CommitViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/14/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class CommitViewModel: BaseTableViewModel<Comment> {
    
    enum SectionType {
        case message
        case changes
        case timeline
    }
    
    var repo: String
    var commit: Variable<Commit>
    var sectionTypes = [SectionType]()
    
    var additions = 0
    var removed = 0
    var modified = 0
    
    init(repo: String, commit: Commit) {
        self.repo = repo
        self.commit = Variable(commit)
        
        super.init()
        
        setSectionTypes()
    }
    
    func fetchFiles() {
        let token = GithubAPI.getACommit(repo: repo, sha: commit.value.sha!)
        
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    if let commit = Mapper<Commit>().map(JSONObject: $0) {
                        self.classifyFiles(ofCommit: commit)
                        self.commit.value = commit
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    override func fetchData() {
        let token = GithubAPI.commitComments(repo: repo, sha: commit.value.sha!, page: page)
        
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
    
    func setSectionTypes() {
        if commit.value.message!.components(separatedBy: "\n").count > 1 {
            sectionTypes.append(.message)
        }
        
        sectionTypes.append(.changes)
        sectionTypes.append(.timeline)
    }

    func numberOfSections() -> Int {
        return sectionTypes.count
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        switch sectionTypes[section] {
        case .message:
            return 1
        case .changes:
            return 4
        case .timeline:
            return dataSource.value.count
        }
    }
    
    func classifyFiles(ofCommit commit: Commit) {
        additions = 0
        removed = 0
        modified = 0
        
        commit.files!.forEach {
            switch $0.status! {
            case .added:
                additions += 1
            case .removed:
                removed += 1
            case .modified, .renamed:
                modified += 1
            }
        }
    }
}
