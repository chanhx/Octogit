//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class IssueViewController: UIViewController {
    
    var webView = WKWebView()
    
    let disposeBag = DisposeBag()
    var viewModel: IssueViewModel! {
        didSet {
            viewModel.fetchData()
            
            viewModel.dataSource.asDriver()
                .drive(onNext: { [unowned self] _ in
                    self.webView.loadHTMLString(self.viewModel.contentHTML, baseURL: Bundle.main.resourceURL)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(netHex: 0xefeff4)
        self.view.addSubview(webView)
        
        navigationItem.title = "#\(viewModel.issue.number!)"
    }
    
}

extension IssueViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.isFileURL {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
        
        let vc = URLRouter.viewController(forURL: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
