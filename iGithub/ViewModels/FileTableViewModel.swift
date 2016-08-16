//
//  FileTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class FileTableViewModel: BaseTableViewModel<File> {
    
    var repository: String
    var path: String
    var token: GithubAPI
    
    init(repository: String, path: String = "") {
        
        self.repository = repository
        self.path = path
        self.token = .GetContents(repo: repository, path: path)
        
        super.init()
    }
    
    var title: String {        
        return (path == "" ? repository : path).componentsSeparatedByString("/").last!
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    self.dataSource.value = Mapper<File>().mapArray($0)!
                },
                onError: {
                    print($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    func fileViewModel(file: File) -> FileViewModel {
        return FileViewModel(repository: repository, file: file)
    }
    
    func subDirectoryViewModel(directory: File) -> FileTableViewModel {
        return FileTableViewModel(repository: repository, path: directory.path!)
    }
}