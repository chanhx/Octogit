//
//  FileViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/25/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit

class FileViewController: UIViewController {

    let webView = WKWebView()
    var viewModel: FileViewModel! {
        didSet {
            viewModel.html.asDriver()
                .filter { $0.characters.count > 0 }
                .drive(onNext: { [unowned self] html in
                    self.webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                })
                .addDisposableTo(viewModel.disposeBag)
            
            viewModel.contentData.asDriver()
                .filter { $0.count > 0 }
                .drive(onNext: { [unowned self] data in
                    self.webView.load(data, mimeType: self.viewModel.mimeType, characterEncodingName: "utf-8", baseURL: Bundle.main.resourceURL!)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        view.addSubview(webView)
        
        navigationItem.title = viewModel.fileName
        if let path = viewModel.filePath, path.characters.count > 0 {
            navigationItem.prompt = path
        }

        viewModel.getFileContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
