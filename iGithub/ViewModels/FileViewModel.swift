//
//  FileViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import Alamofire
import RxMoya
import RxSwift
import ObjectMapper
import Mustache

class FileViewModel {
    
    static let fileExtensionsDict: [String: String] = {
        let path = Bundle.main.path(forResource: "file_extensions", ofType: "plist")
        return (NSDictionary(contentsOfFile: path!) as! [String: String])
    }()
    
    enum GHFile {
        case normalFile(File)
        case commitFile(CommitFile)
        case gistFile(GistFile)
    }
    
    var repo: String?
    var file: GHFile
    var fileName: String
    var filePath: String?
    var ref: String?
    var html = Variable("")
    var contentData = Variable(Data())
    let disposeBag = DisposeBag()
    var mimeType: String {
        let ext = self.fileName.pathExtension
        switch ext {
        case "gif", "jpg", "jpeg", "png", "tif", "tiff":
            return "image/\(ext)"
        case "pdf", "rar", "zip":
            return "application/\(ext)"
        default:
            return "text/\(ext)"
        }
    }
    
    init(repository: String, file: File, ref: String) {
        repo = repository
        self.file = .normalFile(file)
        fileName = file.name!
        filePath = file.path!.components(separatedBy: "/").dropLast().joined(separator: "/")
        self.ref = ref
    }
    
    init(repository: String) {
        repo = repository
        file = .normalFile(Mapper<File>().map(JSON: ["name": "README"])!)
        fileName = "README"
    }
    
    init(file: CommitFile) {
        self.file = .commitFile(file)
        html.value = Renderer.render(file.patch!, language: "diff")
        fileName = file.name
        filePath = file.path!.components(separatedBy: "/").dropLast().joined(separator: "/")
    }
    
    init(file: GistFile) {
        self.file = .gistFile(file)
        fileName = file.name!
    }
    
    func getFileContent() {
        switch file {
        case .normalFile(let f):
            fetch(file: f)
        case .gistFile(let f):
            fetch(gistFile: f)
        case .commitFile:
            break
        }
    }
    
    func fetch(file: File) {
        switch fileName {
        case "README", "LICENSE":
            fetchHTMLContent(file)
            return
        default: break
        }
        
        switch fileName.pathExtension {
        case "md", "markdown", "adoc", "txt":
            fetchHTMLContent(file)
            return
        default:
            fetchContent(file)
        }
    }
    
    func fetchContent(_ file: File) {
        let token = GithubAPI.getContents(repo: repo!, path: file.path!, ref: ref!)
        
        GithubProvider
            .request(token)
            .mapJSON()
            .subscribe(
                onNext: {
                    let normalFile = Mapper<File>().map(JSONObject: $0)!
                    self.file = .normalFile(normalFile)
                    
                    let type = self.mimeType.components(separatedBy: "/")[0]
                    switch type {
                    case "image":
                        self.contentData.value = Data.dataFromGHBase64String(normalFile.content!)!
                    default:
                        let rawContent = String.stringFromGHBase64String(normalFile.content!)
                        let language = self.language(ofFile: normalFile.name!)
                        self.html.value = self.htmlForRawFile(rawContent, language: language)
                    }
                },
                onError: {
                    MessageManager.show(error: $0)
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    func fetchHTMLContent(_ file: File) {
        let token: GithubAPI
        if let path = file.path {
            token = GithubAPI.getHTMLContents(repo: repo!, path: path, ref: ref!)
        } else {
            token = GithubAPI.getTheREADME(repo: repo!)
        }
        
        GithubProvider
            .request(token)
            .mapString()
            .subscribe(onNext: {
                self.html.value = self.htmlForMarkdown($0)
            })
            .addDisposableTo(disposeBag)
    }
    
    func fetch(gistFile: GistFile) {
        Alamofire.request(gistFile.rawURL!).responseString { response in
            if response.result.isSuccess {
                let language = self.language(ofFile: gistFile.name!)
                self.html.value = self.htmlForRawFile(response.result.value!, language:language)
            }
        }
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
    
    func htmlForRawFile(_ rawContent: String?, language: String? = nil) -> String {
        if let _ = rawContent {
            return Renderer.render(rawContent!, language: language ?? "clike")
        } else {
            let url = Bundle.main.url(forResource: "empty_content", withExtension: "html")
            return try! String(contentsOf: url!)
        }
    }
    
    func language(ofFile fileName: String) -> String? {
        let fileExtension = fileName.components(separatedBy: ".").last!
        return FileViewModel.fileExtensionsDict[fileExtension]
    }
}
