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
    
    enum InfoType {
        case author
        case description
        case homepage
        case readme
    }
    
    var fullName: String
    let disposeBag = DisposeBag()
    var repository: Variable<Repository>
    var isRepositoryLoaded = false
    
    var branches = [Branch]()
    var pageForBranches = 1
    var isBranchesLoaded = Variable(false)
    var branch: String!
    
    var infoTypes = [InfoType]()
    
    init(repo: Repository) {
        self.fullName = repo.fullName!
        self.repository = Variable(repo)
    }
    
    init(fullName: String) {
        self.fullName = fullName
        
        let name = fullName.components(separatedBy: "/").last!
        self.repository = Variable(Mapper<Repository>().map(JSON: ["name": "\(name)"])!)
    }
    
    func fetchRepository() {
        GithubProvider
            .request(.getARepository(repo: fullName))
            .mapJSON()
            .subscribe(onNext: {
                // first check if there is an error and if the repo exists
//                if $0.statusCode == 404 {
//                    
//                }
                
                if let repo = Mapper<Repository>().map(JSONObject: $0) {
                    self.setInfoTypes(repo: repo)
                    self.isRepositoryLoaded = true
                    self.branch = repo.defaultBranch!
                    self.rearrangeBranches(withDefaultBranch: repo.defaultBranch!)
                    self.repository.value = repo
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func fetchBranches() {
        let token = GithubAPI.branches(repo: fullName, page: pageForBranches)
        
        GithubProvider
            .request(token)
            .subscribe(onNext: {
                
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
    
    var numberOfSections: Int {
        return self.isRepositoryLoaded ? 3 : 1
    }
    
    func setInfoTypes(repo: Repository) {
        
        infoTypes.removeAll()
        infoTypes.append(.author)
        
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
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard self.isRepositoryLoaded else {
            return 1
        }
        
        switch section {
        case 0:
            return infoTypes.count
        case 1:
            return 2
        default:
            return 5
        }
    }
    
    // MARK: generate child viewmodel
    
    var fileTableViewModel: FileTableViewModel {
        return FileTableViewModel(repository: fullName, ref: branch)
    }
    
    var commitTableViewModel: CommitTableViewModel {
        return CommitTableViewModel(repo: repository.value, branch: branch)
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
