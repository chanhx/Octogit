//
//  FileViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class FileViewController: UIViewController {

    let webView = UIWebView()
    var viewModel: FileViewModel! {
        didSet {
            viewModel.decodedContent.asObservable()
                .subscribeNext {
                    self.webView.loadHTMLString("<pre>\($0)</pre>", baseURL: nil)
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
