//
//  OAuthViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import WebKit

class OAuthViewController: WebViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = OAuthConfiguration.authorizationURL {
            webView.load(URLRequest(url: url as URL))
        }
    }
    
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        guard url.lastPathComponent == OAuthConfiguration.callbackMark else {
            decisionHandler(.allow)
            return
        }
        
        guard
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let code = queryItems.filter({$0.name == "code"}).first?.value
        else {
            decisionHandler(.cancel)
            return
        }
        
        AccountManager.requestToken(code, success: {
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.delegate!.window!!.rootViewController = mainVC
        }, failure: {
            MessageManager.show(error: $0)
            _ = self.navigationController?.popViewController(animated: true)
        })
        
        decisionHandler(.cancel)
        
    }
}
