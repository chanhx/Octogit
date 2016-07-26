//
//  FileViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import Mustache

class FileViewController: UIViewController {

    let webView = WKWebView()
    var viewModel: FileViewModel! {
        didSet {
            viewModel.decodedContent.asObservable()
                .subscribeNext {
//                    do {
                    let template = try! Template(named: "content")
                    
                    var codeClass = ""
                    if let language = self.viewModel.languageOfFile {
                        codeClass = "class=language-\(language)"
                    }
                    let data = [
                        "theme": "prism",
                        "content": $0,
                        "line-numbers": "class=line-numbers",
                        "class": codeClass
                    ]
                    let rendering = try! template.render(Box(data))
                
                    self.webView.loadHTMLString(rendering, baseURL: NSBundle.mainBundle().resourceURL)
//                    } catch let error as MustacheError {
//                        
//                    }
            }
            .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        self.view.addSubview(webView)
        
        self.navigationItem.title = viewModel.file.name
        
        viewModel.fetchContent()
    }
    
}
