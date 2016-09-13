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
            viewModel.html.asObservable()
                .skipWhile { $0.characters.count <= 0 }
                .subscribeNext {
                    self.webView.loadHTMLString($0, baseURL: NSBundle.mainBundle().resourceURL)
                }
                .addDisposableTo(viewModel.disposeBag)
            
            viewModel.contentData.asObservable()
                .skipWhile { $0.length <= 0 }
                .subscribeNext {
                    self.webView.loadData($0, MIMEType: self.viewModel.file.MIMEType, characterEncodingName: "utf-8", baseURL: NSBundle.mainBundle().resourceURL!)
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        self.view.addSubview(webView)
        
        self.navigationItem.title = viewModel.file.name
        
        viewModel.fetch()
    }
    
}
