//
//  FileViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxMoya
import RxSwift
import ObjectMapper

class FileViewModel: NSObject {
    
    var repository: String
    var token: GithubAPI
    var file: File
    var decodedContent = Variable("")
    let provider = RxMoyaProvider<GithubAPI>()
    let disposeBag = DisposeBag()
    
    init(repository: String, file: File) {
        
        self.repository = repository
        self.file = file
        token = .GetContents(repository: repository, path: file.path!)
        
        super.init()
    }
    
    func fetchContent() {
        provider
            .request(token)
            .mapJSON()
            .subscribeNext {
                self.file = Mapper<File>().map($0)!
                self.decodedContent.value = self.decodeGHBase64String(self.file.content!)
            }
            .addDisposableTo(disposeBag)
    }
    
    func decodeGHBase64String(string: String) -> String {
        let encodedString = string.stringByReplacingOccurrencesOfString("\n", withString: "")
        let data = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: NSUTF8StringEncoding)!
    }
}
