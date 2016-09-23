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

class FileViewModel {
    
    static let fileExtensionsDict: [String: String] = {
        let path = Bundle.main.path(forResource: "file_extensions", ofType: "plist")
        return (NSDictionary(contentsOfFile: path!) as! [String: String])
    }()
    
    var repo: String
    var file: File
    var html = Variable("")
    var contentData = Variable(Data())
    let disposeBag = DisposeBag()
    
    init(repository: String, file: File) {
        repo = repository
        self.file = file
    }
    
    init(repository: String) {
        repo = repository
        file = Mapper<File>().map(JSON: ["name": "README"])!
    }
    
    func fetch() {
        switch self.file.name! {
        case "README", "LICENSE":
            fetchHTMLContent()
            return
        default: break
        }
        
        switch self.file.name!.pathExtension {
        case "md", "markdown", "adoc", "txt":
            fetchHTMLContent()
            return
        default:
            fetchContent()
        }
    }
    
    func fetchContent() {
        let token = GithubAPI.getContents(repo: repo, path: file.path!)
        
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe {
                self.file = Mapper<File>().map(JSONObject: $0)!
                
                let type = self.file.MIMEType.components(separatedBy: "/")[0]
                switch type {
                case "image":
                    self.contentData.value = Data.dataFromGHBase64String(self.file.content!)!
                default:
                    self.html.value = self.htmlForRawFile(self.file.content!)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func fetchHTMLContent() {
        let token: GithubAPI
        if let path = file.path {
            token = GithubAPI.getHTMLContents(repo: repo, path: path)
        } else {
            token = GithubAPI.getTheREADME(repo: repo)
        }
        
        GithubProvider
            .request(token)
            .mapString()
            .subscribeNext {
                self.html.value = self.htmlForMarkdown($0)
            }
            .addDisposableTo(disposeBag)
    }
    
    func htmlForMarkdown(_ markdown: String?) -> String {
        
        if let upwarppedMarkdown = markdown {
            let template = try! Template(named: "markdown")
            let data = ["content": upwarppedMarkdown]
            
            return try! template.render(Box(data))
        }
        let url = Bundle.main.url(forResource: "empty_content", withExtension: "html")
        return try! String(contentsOf: url!)
    }
    
    func htmlForRawFile(_ base64String: String) -> String {
        
        if let rawContent = String.stringFromGHBase64String(base64String) {
            return Renderer.render(rawContent, language: languageOfFile ?? "clike")
        }
        let url = Bundle.main.url(forResource: "empty_content", withExtension: "html")
        return try! String(contentsOf: url!)
    }
    
    var languageOfFile: String? {
        let fileExtension = file.name?.components(separatedBy: ".").last!
        return FileViewModel.fileExtensionsDict[fileExtension!]
    }
}
