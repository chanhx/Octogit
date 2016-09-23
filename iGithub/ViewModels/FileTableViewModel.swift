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
        self.token = .getContents(repo: repository, path: path)
        
        super.init()
    }
    
    var title: String {        
        return (path == "" ? repository : path).components(separatedBy: "/").last!
    }
    
    override func fetchData() {
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe {
                self.dataSource.value = Mapper<File>().mapArray(JSONObject: $0)!
                    .map {
                        if $0.type! == .file && $0.size == 0 {
                            $0.type = .submodule
                        }
                        return $0
                    }.sorted(by: { (f1, f2) -> Bool in
                        if f1.type! == f2.type! {
                            return f1.name! < f2.name!
                        } else {
                            switch (f1.type!, f2.type!) {
                            case (.directory, _), (_, .directory):
                                return f1.type! == .directory
                            case (.submodule, _), (_, .submodule):
                                return f1.type! == .submodule
                            case (.file, _), (_, .file):
                                return f1.type! == .file
                            case (.symlink, _), (_, .symlink):
                                return f1.type! == .symlink
                            default:
                                return true
                            }
                        }
                })
            }
            .addDisposableTo(disposeBag)
    }
    
    func fileViewModel(_ file: File) -> FileViewModel {
        return FileViewModel(repository: repository, file: file)
    }
    
    func subDirectoryViewModel(_ directory: File) -> FileTableViewModel {
        return FileTableViewModel(repository: repository, path: directory.path!)
    }
}
