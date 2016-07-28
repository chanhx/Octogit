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

class RepositoryViewModel: NSObject {
    
    var fullName: String
    let provider = RxMoyaProvider<GithubAPI>()
    let disposeBag = DisposeBag()
    var repository: Variable<Repository>
    var repositoryLoaded = false
    
    init(fullName: String) {
        self.fullName = fullName
        
        let name = fullName.componentsSeparatedByString("/").last!
        self.repository = Variable(Mapper<Repository>().map(["name": "\(name)"])!)
        
        super.init()
    }
    
    func fetchRepository() {
        provider
            .request(.GetARepository(fullName: fullName))
            .mapJSON()
            .subscribeNext {
                // first check if there is an error and if the repo exists
//                if $0.statusCode == 404 {
//                    
//                }
                self.repositoryLoaded = true
                self.repository.value = Mapper<Repository>().map($0)!
            }
            .addDisposableTo(disposeBag)
    }
    
    var numberOfSections: Int {
        return self.repositoryLoaded ? 3 : 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        guard self.repositoryLoaded else {
            return 1
        }
        
        switch section {
        case 0:
            return self.repository.value.repoDescription != nil ? 2 : 1
        case 1:
            return 5
        default:
            return 2
        }
    }
    
    // MARK: generate child viewmodel
    
    var filesTableViewModel: FilesTableViewModel {
        return FilesTableViewModel(repository: fullName)
    }

    var ownerViewModel: UserViewModel {
        return UserViewModel(user: repository.value.owner!)
    }
}