//
//  OAuthViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import WebKit

class OAuthViewController: WebViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = OAuthConfiguration.authorizationURL {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.URL?.lastPathComponent == OAuthConfiguration.callbackMark {
            
            let queryItems = NSURLComponents(URL: navigationAction.request.URL!, resolvingAgainstBaseURL: false)?.queryItems
            if let code = queryItems?.filter({$0.name == "code"}).first!.value {
                AccountManager.shareManager.requestToken(code, success: {
                    let navigationVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let eventTVC = navigationVC.topViewController as! EventTableViewController
                    eventTVC.viewModel = EventTableViewModel(user: AccountManager.shareManager.currentUser!, type: .Received)
                    UIApplication.sharedApplication().delegate!.window!!.rootViewController = eventTVC
                }, failure: {
                    print($0)
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            decisionHandler(.Cancel)
        }
        
        decisionHandler(.Allow)
    }
}
