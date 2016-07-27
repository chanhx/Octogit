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
                .subscribeNext {
                    self.webView.loadHTMLString($0, baseURL: NSBundle.mainBundle().resourceURL)
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
