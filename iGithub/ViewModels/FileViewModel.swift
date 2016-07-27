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
import Mustache

class FileViewModel: NSObject {
    
    static let fileExtensionsDict: [String: String] = {
        let path = NSBundle.mainBundle().pathForResource("file_extensions", ofType: "plist")
        return (NSDictionary(contentsOfFile: path!) as! [String: String])
    }()
    
    var repository: String
    var token: GithubAPI
    var file: File
    var html = Variable("")
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
                self.html.value = self.htmlFrom(self.file.content!)
            }
            .addDisposableTo(disposeBag)
    }
    
    func htmlFrom(base64String: String) -> String {
        
        if let rawContent = decodeGHBase64String(base64String) {
            let template = try! Template(named: "content")
            
            let data = [
                "theme": "prism",
                "content": rawContent,
                "line-numbers": "class=line-numbers",
                "class": languageOfFile ?? "clike"
            ]
            return try! template.render(Box(data))
        }
        let url = NSBundle.mainBundle().URLForResource("empty_content", withExtension: "html")
        let html = try! String(contentsOfURL: url!)
        
        return html
    }
    
    func decodeGHBase64String(string: String) -> String? {
        let encodedString = string.stringByReplacingOccurrencesOfString("\n", withString: "")
        let data = NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: NSUTF8StringEncoding)
    }
    
    var languageOfFile: String? {
        let fileExtension = file.name?.componentsSeparatedByString(".").last!
        return FileViewModel.fileExtensionsDict[fileExtension!]
    }
}
