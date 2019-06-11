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
    var sha: String
    var commit = Variable<Commit?>(nil)
    var sectionTypes = [SectionType]()
    var shortSHA: String {
        return sha.substring(to: 7)
    }
    
    var additions = 0
    var removed = 0
    var modified = 0
    
    init(repo: String, commit: Commit) {
        self.repo = repo
        self.sha = commit.sha
        self.commit.value = commit
        
        super.init()
        
        setSectionTypes(withCommit: commit)
    }
    
    init(repo: String, sha: String) {
        self.repo = repo
        self.sha = sha
        
        super.init()
    }
    
    func fetchFiles() {
        let token = GitHubAPI.commit(repo: repo, sha: sha)
        
        GitHubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    if let commit = Mapper<Commit>().map(JSONObject: $0) {
                        self.classifyFiles(ofCommit: commit)
                        self.setSectionTypes(withCommit: commit)
                        self.commit.value = commit
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func fetchData() {
        let token = GitHubAPI.commitComments(repo: repo, sha: sha, page: page)
        
        GitHubProvider
            .request(token)
            .do(onNext: { [unowned self] in
                if let headers = $0.response?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    if let newComments = Mapper<Comment>().mapArray(JSONObject: $0) {
                        self.dataSource.value.append(contentsOf: newComments)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func setSectionTypes(withCommit commit: Commit) {
        sectionTypes.removeAll()
        
        if commit.message!.components(separatedBy: "\n").count > 1 {
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
