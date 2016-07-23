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
    var repositoryLoaded: Bool = false
    
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
}