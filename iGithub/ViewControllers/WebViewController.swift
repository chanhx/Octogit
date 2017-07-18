//
//  WebViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/7/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView = WKWebView()
    var showNativeController = true
    
    fileprivate var request: URLRequest?
    fileprivate var progressView = UIProgressView(progressViewStyle: .bar)
    
    fileprivate var toolbarWasHidden: Bool!
    
    fileprivate var kvoContext: UInt8 = 0
    fileprivate let keyPaths = ["title", "loading", "estimatedProgress"]
    
    convenience init(address: String, userScript: WKUserScript? = nil) {
        self.init(url: URL(string: address)!, userScript: userScript)
    }
    
    convenience init(url: URL, userScript: WKUserScript? = nil) {
        self.init(request: URLRequest(url: url), userScript: userScript)
    }
    
    init(request: URLRequest, userScript: WKUserScript? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.request = request
        
        if let script = userScript {
            let userContentController = WKUserContentController()
            userContentController.addUserScript(script)
            
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = userContentController
            
            webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView.stopLoading()
        webView.navigationDelegate = nil
        
        progressView.removeFromSuperview()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        for keyPath in keyPaths {
            webView.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        progressView.frame = CGRect(x: 0, y: 42, width: view.bounds.width, height: 2)
        progressView.trackTintColor = UIColor.clear
        self.navigationController?.navigationBar.addSubview(progressView)
        
        updateToolbar()
        
        for keyPath in keyPaths {
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: &kvoContext)
        }
        
        if request != nil {
            webView.load(request!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toolbarWasHidden = self.navigationController?.isToolbarHidden
        navigationController?.isToolbarHidden = false
        
        progressView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isToolbarHidden = toolbarWasHidden
        
        progressView.isHidden = true
    }
    
    func updateToolbar() {
        let backItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: webView, action: #selector(WKWebView.goBack))
        let forwardItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .plain, target: webView, action: #selector(WKWebView.goForward))
        let loadItem: UIBarButtonItem = {
            if webView.isLoading {
                return UIBarButtonItem(barButtonSystemItem: .stop, target: webView, action: #selector(WKWebView.stopLoading))
            } else {
                return UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(WKWebView.reload))
            }
        }()
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WebViewController.share(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        backItem.isEnabled = webView.canGoBack
        forwardItem.isEnabled = webView.canGoForward
        
        self.setToolbarItems([flexibleSpace, backItem, flexibleSpace, forwardItem, flexibleSpace, loadItem, flexibleSpace, shareItem, flexibleSpace],
                             animated: false)
    }
    
    func share(_ button: UIBarButtonItem) {
        var items = [Any]()
        if webView.title != nil {
            items.append(webView.title!)
        }
        if request?.url != nil {
            items.append(request!.url!)
        }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: [ActivitySafari()])
        activityVC.popoverPresentationController?.barButtonItem = button
        self.navigationController?.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if keyPath == "title" {
                navigationItem.title = webView.title
            } else if keyPath == "loading" {
                updateToolbar()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
            } else if keyPath == "estimatedProgress" {
                
                let progress = Float(webView.estimatedProgress)
                let animated = progress > progressView.progress
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.setProgress(progress, animated: animated)
                    if self.webView.estimatedProgress >= 1 {
                        self.progressView.alpha = 0
                    }
                }) { _ in
                    self.progressView.alpha = self.webView.estimatedProgress >= 1 ? 0 : 1
                }
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        guard showNativeController, let vc = URLRouter.nativeViewController(forURL: url) else {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class ActivitySafari: UIActivity {
    
    fileprivate var url: URL!
    
    open override var activityType : UIActivityType? {
        return UIActivityType("me.hochueng.activity.WebViewController")
    }
    override var activityTitle : String? {
        return "Open in Safari"
    }
    override var activityImage : UIImage? {
        return UIImage(named: "safari")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if item is URL && UIApplication.shared.canOpenURL(item as! URL) {
                return true
            }
        }
        return true
    }
    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if item is URL {
                url = item as! URL
            }
        }
    }
    override func perform() {
        let completed = UIApplication.shared.openURL(url)
        activityDidFinish(completed)
    }
}
