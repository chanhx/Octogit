//
//  PullRequestViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/09/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class PullRequestViewController: UIViewController {
    
    let indicator = LoadingIndicator()
    let webView = WKWebView()
    
    let disposeBag = DisposeBag()
    var viewModel: PullRequestViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(netHex: 0xefeff4)
        self.view.addSubview(webView)
        
        self.show(indicator: indicator, onView: webView)
        
        navigationItem.title = "#\(viewModel.number)"
        
        viewModel.html.asDriver()
            .flatMap { Driver.from(optional: $0) }
            .drive(onNext: { [unowned self] in
                self.webView.loadHTMLString($0, baseURL: Bundle.main.resourceURL)
                self.indicator.removeFromSuperview()
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchData()
    }
    
}

extension PullRequestViewController: WKNavigationDelegate {

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
