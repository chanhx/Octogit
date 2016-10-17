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
    var repositoryLoaded = false
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
                    self.repositoryLoaded = true
                    self.repository.value = repo
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        return self.repositoryLoaded ? 3 : 1
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
        guard self.repositoryLoaded else {
            return 1
        }
        
        switch section {
        case 0:
            return infoTypes.count
        case 1:
            return 5
        default:
            return 2
        }
    }
    
    // MARK: generate child viewmodel
    
    var filesTableViewModel: FileTableViewModel {
        return FileTableViewModel(repository: fullName)
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
