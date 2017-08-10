//
//  RepositoryViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya
import RxSwift
import ObjectMapper

class RepositoryViewModel {
    
    enum Section {
        case info
        case code
        case misc
        case loading
    }
    
    enum InfoType {
        case author
        case parent
        case mirror
        case description
        case homepage
        case readme
    }
    
    enum MiscType {
        case issues
        case pullRequests
        case releases
        case contributors
        case activity
    }
    
    var owner: String
    var name: String
    var nameWithOwner: String {
        return "\(owner)/\(name)"
    }
    let disposeBag = DisposeBag()
    var repository: Variable<Repository>
    var hasStarred: Variable<Bool?> = Variable(nil)
    var isRepositoryLoaded = false
    
    var branches = [Branch]()
    var pageForBranches = 1
    var isBranchesLoaded = Variable(false)
    var branch: String!
    
    var sections = [Section]()
    var infoTypes = [InfoType]()
    var miscTypes = [MiscType]()
    
    lazy var information: String = {
        var information: String = "Check out the repository \(self.nameWithOwner)."
        if let description = self.repository.value.repoDescription,
            description.characters.count > 0 {
            information.append(" \(description)")
        }
        
        return information
    }()
    lazy var htmlURL: URL = {
        return URL(string: "https://github.com/\(self.nameWithOwner)")!
    }()
    
    init(repo: Repository) {
        self.name = repo.name
        self.owner = repo.owner!.login
        self.repository = Variable(repo)
    }
    
    init(repo: String) {
        let nameComponents = repo.components(separatedBy: "/")
        self.owner = nameComponents[0]
        self.name = nameComponents[1]
        self.repository = Variable(Mapper<Repository>().map(JSON: ["name": "\(name)"])!)
    }
    
    func fetchRepository() {
        GitHubProvider
            .request(.repository(owner:owner, name:name))
            .filterSuccessfulStatusAndRedirectCodes()
            .mapJSON()
            .subscribe(onNext: { [unowned self] in
                
                guard
                    let json = $0 as? [String : [String : Any]],
                    let repo = Mapper<Repository>().map(JSONObject: json["data"]?["repository"])
                else {
//                    let message =
                    return
                }
                
                self.isRepositoryLoaded = true
                self.branch = repo.defaultBranch!
                self.rearrangeBranches(withDefaultBranch: repo.defaultBranch!)
                self.repository.value = repo
                self.hasStarred.value = repo.hasStarred!
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Branches
    
    func fetchBranches() {
        let token = GitHubAPI.branches(repo: nameWithOwner, page: pageForBranches)
        
        GitHubProvider
            .request(token)
            .subscribe(onNext: { [unowned self] in
                
                if let json = try? $0.mapJSON(), let newBranches = Mapper<Branch>().mapArray(JSONObject: json) {
                    self.branches.append(contentsOf: newBranches)
                }
                
                if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields {
                    if let _ = (headers["Link"] as? String)?.range(of: "rel=\"next\"") {
                        self.pageForBranches += 1
                        self.fetchBranches()
                    } else {
                        self.isBranchesLoaded.value = true
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func rearrangeBranches(withDefaultBranch defaultBranch: String) {
        for (index, branch) in self.branches.enumerated() {
            if branch.name! == defaultBranch {
                let _ = self.branches.remove(at: index)
                branches.insert(branch, at: 0)
                
                break
            }
        }
    }
    
    func toggleStarring() {
        let token: GitHubAPI = repository.value.hasStarred! ? .unstar(repo: nameWithOwner) : .star(repo: nameWithOwner)
        
        GitHubProvider
            .request(token)
            .subscribe(onNext: { [unowned self] response in
                if response.statusCode == 204 {
                    self.hasStarred.value = !self.hasStarred.value!
                } else {
                    let json = try! response.mapJSON()
                    print(json)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        setSections()
        return sections.count
    }
    
    func setSections() {
        sections = []
        
        guard self.isRepositoryLoaded else {
            sections.append(.loading)
            return
        }
        
        sections.append(.info)
        if let _ = repository.value.defaultBranch {
            sections.append(.code)
        }
        sections.append(.misc)
    }
    
    func setInfoTypes(repo: Repository) {
        
        if !isRepositoryLoaded || infoTypes.count > 0 {
            return
        }
        
        infoTypes.append(.author)
        
        if let _ = repo.parent {
            infoTypes.append(.parent)
        }
        
        if let _ = repo.mirrorURL {
            infoTypes.append(.mirror)
        }
        
        if let desc = repo.repoDescription?.trimmingCharacters(in: .whitespacesAndNewlines),
            desc.characters.count > 0 {
            infoTypes.append(.description)
        }
        
        if let homepage = repo.homepage?.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines),
            homepage.characters.count > 0 {
            infoTypes.append(.homepage)
        }
        
        infoTypes.append(.readme)
    }
    
    func setMiscTypes(repo: Repository) {
        
        if !isRepositoryLoaded || miscTypes.count > 0 {
            return
        }
        
        if repo.hasIssuesEnabled! {
            miscTypes.append(.issues)
        }
        
        miscTypes += [.pullRequests, .releases, .contributors, .activity]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch sections[section] {
        case .info:
            setInfoTypes(repo: repository.value)
            return infoTypes.count
        case .code:
            return 2
        case .misc:
            setMiscTypes(repo: repository.value)
            return miscTypes.count
        case .loading:
            return 1
        }
    }
    
    // MARK: generate child viewmodel
    
    var readmeViewModel: FileViewModel {
        return FileViewModel(repository: nameWithOwner, ref: branch)
    }
    
    var fileTableViewModel: FileTableViewModel {
        return FileTableViewModel(repository: nameWithOwner, ref: branch)
    }
    
    var commitTableViewModel: CommitTableViewModel {
        return CommitTableViewModel(repo: nameWithOwner, branch: branch)
    }

    var ownerViewModel: UserViewModel {
        switch repository.value.owner!.type! {
        case .user:
            return UserViewModel(repository.value.owner!)
        case .organization:
            return OrganizationViewModel(repository.value.owner!)
        }
    }
}
