//
//  DirectoryTableViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

class FilesTableViewModel: BaseTableViewModel<File> {
    
    var repository: String
    var path: String
    var token: GithubAPI
    
    init(repository: String, path: String = "") {
        
        self.repository = repository
        self.path = path
        self.token = .GetContents(repository: repository, path: path)
        
        super.init()
    }
    
    var title: String {        
        return (path == "" ? repository : path).componentsSeparatedByString("/").last!
    }
    
    override func fetchData() {
        provider
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
    
    func subDirectoryViewModel(directory: File) -> FilesTableViewModel {
        return FilesTableViewModel(repository: repository, path: directory.path!)
    }
}