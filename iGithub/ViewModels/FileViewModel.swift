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
        let path = NSBundle.mainBundle().pathForResource("file_extensions", ofType: "plist")
        return (NSDictionary(contentsOfFile: path!) as! [String: String])
    }()
    
    var repo: String
    var file: File
    var html = Variable("")
    let disposeBag = DisposeBag()
    
    init(repository: String, file: File) {
        repo = repository
        self.file = file
    }
    
    init(repository: String) {
        repo = repository
        file = Mapper<File>().map(["name": "README"])!
    }
    
    func fetch() {
        switch self.file.name! {
        case "README", "LICENSE":
            fetchHTMLContent()
            return
        default: break
        }
        
        switch self.file.name!.componentsSeparatedByString(".").last! {
        case "md", "markdown", "adoc", "txt":
            fetchHTMLContent()
            return
        case "gif", "jpg", "png", "mp3", "mp4":
            break
        case "rar", "zip":
            break
        default:
            fetchContent()
        }
    }
    
    func fetchContent() {
        let token = GithubAPI.GetContents(repo: repo, path: file.path!)
        
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribeNext {
                self.file = Mapper<File>().map($0)!
                self.html.value = self.htmlForRawFile(self.file.content!)
            }
            .addDisposableTo(disposeBag)
    }
    
    func fetchHTMLContent() {
        let token: GithubAPI
        if let path = file.path {
            token = GithubAPI.GetHTMLContents(repo: repo, path: path)
        } else {
            token = GithubAPI.GetTheREADME(repo: repo)
        }
        
        GithubProvider
            .request(token)
            .mapString()
            .subscribeNext {
                self.html.value = self.htmlForMarkdown($0)
            }
            .addDisposableTo(disposeBag)
    }
    
    func htmlForMarkdown(markdown: String?) -> String {
        
        if let upwarppedMarkdown = markdown {
            let template = try! Template(named: "markdown")
            
            let data: [String: AnyObject] = [
                "content": upwarppedMarkdown,
            ]
            return try! template.render(Box(data))
        }
        let url = NSBundle.mainBundle().URLForResource("empty_content", withExtension: "html")
        let html = try! String(contentsOfURL: url!)
        
        return html
    }
    
    func htmlForRawFile(base64String: String) -> String {
        
        if let rawContent = decodeGHBase64String(base64String) {
            return Renderer.render(rawContent, language: languageOfFile ?? "clike")
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
