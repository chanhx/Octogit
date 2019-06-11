//
//  CommitFileTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class CommitFileTableViewModel: BaseTableViewModel<CommitFile> {
    
    var repo: String?
    var pullRequestNumber: Int?
    
    init(repo: String, pullRequestNumber: Int) {
        self.repo = repo
        self.pullRequestNumber = pullRequestNumber
        
        super.init()
    }
    
    init(files: [CommitFile]) {
        super.init()
        
        self.dataSource.value = files
    }
    
    override func fetchData() {
        let token = GitHubAPI.pullRequestFiles(repo: repo!, number: pullRequestNumber!, page: page)

        GitHubProvider
            .request(token)
            .filterSuccessfulStatusAndRedirectCodes()
            .do(onNext: { [unowned self] in
                if let headers = $0.response?.allHeaderFields {
                    self.hasNextPage = (headers["Link"] as? String)?.range(of: "rel=\"next\"") != nil
                }
            })
            .mapJSON()
            .subscribe(
                onSuccess: { [unowned self] in
                    if let newFiles = Mapper<CommitFile>().mapArray(JSONObject: $0) {
                        if self.page == 1 {
                            self.dataSource.value = newFiles
                        } else {
                            self.dataSource.value.append(contentsOf: newFiles)
                        }
                        
                        self.page += 1
                    }
                },
                onError: { [unowned self] in
                    self.error.value = $0
                }
            )
            .disposed(by: disposeBag)
    }
    
    func fileViewModel(forRow row: Int) -> FileViewModel {
        return FileViewModel(file: dataSource.value[row])
    }
}
