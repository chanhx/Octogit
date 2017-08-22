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
    let indicator = LoadingIndicator()
    
    var viewModel: FileViewModel! {
        didSet {
            viewModel.html.asDriver()
                .filter { $0.characters.count > 0 }
                .drive(onNext: { [unowned self] html in
                    self.indicator.removeFromSuperview()
                    self.webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                })
                .addDisposableTo(viewModel.disposeBag)
            
            viewModel.contentData.asDriver()
                .filter { $0.count > 0 }
                .drive(onNext: { [unowned self] data in
                    self.indicator.removeFromSuperview()
                    self.webView.load(data, mimeType: self.viewModel.mimeType, characterEncodingName: "utf-8", baseURL: Bundle.main.resourceURL!)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        webView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 30),
            indicator.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        indicator.startAnimating()
        
        navigationItem.title = viewModel.fileName
        if let path = viewModel.filePath, path.characters.count > 0 {
            navigationItem.prompt = path
        }

        viewModel.getFileContent()
    }
}

extension FileViewController: WKNavigationDelegate {
    
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
