//
//  WebViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/7/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView = WKWebView()
    private var request: NSURLRequest?
    private var progressView = UIProgressView(progressViewStyle: .Default)
    
    private var toolbarWasHidden: Bool!
    
    private var kvoContext: UInt8 = 0
    private let keyPaths = ["title", "loading", "estimatedProgress"]
    
    convenience init(address: String, userScript: WKUserScript? = nil) {
        self.init(url: NSURL(string: address)!, userScript: userScript)
    }
    
    convenience init(url: NSURL, userScript: WKUserScript? = nil) {
        self.init(request: NSURLRequest(URL: url), userScript: userScript)
    }
    
    init(request: NSURLRequest, userScript: WKUserScript? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.request = request
        
        if let script = userScript {
            let userContentController = WKUserContentController()
            userContentController.addUserScript(script)
            
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = userContentController
            
            webView = WKWebView(frame: CGRectZero, configuration: configuration)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView.stopLoading()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        webView.navigationDelegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        progressView.frame = CGRectMake(0, 64, view.bounds.width, 2)
        progressView.trackTintColor = UIColor.clearColor()
        self.view.addSubview(progressView)
        
        updateToolbar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toolbarWasHidden = self.navigationController?.toolbarHidden
        navigationController?.toolbarHidden = false
        
        for keyPath in keyPaths {
            webView.addObserver(self, forKeyPath: keyPath, options: .New, context: &kvoContext)
        }
        
        if request != nil {
            webView.loadRequest(request!)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.toolbarHidden = toolbarWasHidden
        
        for keyPath in keyPaths {
            webView.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    func updateToolbar() {
        let backItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: webView, action: #selector(WKWebView.goBack))
        let forwardItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .Plain, target: webView, action: #selector(WKWebView.goForward))
        let loadItem: UIBarButtonItem = {
            if webView.loading {
                return UIBarButtonItem(barButtonSystemItem: .Stop, target: webView, action: #selector(WKWebView.stopLoading))
            } else {
                return UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(WKWebView.reload))
            }
        }()
        let shareItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(WebViewController.share(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        backItem.enabled = webView.canGoBack
        forwardItem.enabled = webView.canGoForward
        
        self.setToolbarItems([flexibleSpace, backItem, flexibleSpace, forwardItem, flexibleSpace, loadItem, flexibleSpace, shareItem, flexibleSpace],
                             animated: false)
    }
    
    func share(button: UIBarButtonItem) {
        var items = [AnyObject]()
        if webView.title != nil {
            items.append(webView.title!)
        }
        if request?.URL != nil {
            items.append(request!.URL!)
        }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: [ActivitySafari()])
        activityVC.popoverPresentationController?.barButtonItem = button
        self.navigationController?.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            if keyPath == "title" {
                navigationItem.title = webView.title
            } else if keyPath == "loading" {
                updateToolbar()
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = webView.loading
            } else if keyPath == "estimatedProgress" {
                
                let progress = Float(webView.estimatedProgress)
                let animated = progress > progressView.progress
                
                UIView.animateWithDuration(0.1, delay: 0.1, options: .CurveEaseOut, animations: {
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

class ActivitySafari: UIActivity {
    
    private var url: NSURL!
    
    override func activityType() -> String? {
        return "me.hochueng.activity.WebViewController"
    }
    override func activityTitle() -> String? {
        return "Open in Safari"
    }
    override func activityImage() -> UIImage? {
        return UIImage(named: "safari")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if item.isKindOfClass(NSURL.self) && UIApplication.sharedApplication().canOpenURL(item as! NSURL) {
                return true
            }
        }
        return true
    }
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for item in activityItems {
            if item.isKindOfClass(NSURL.self) {
                url = item as! NSURL
            }
        }
    }
    override func performActivity() {
        let completed = UIApplication.sharedApplication().openURL(url)
        activityDidFinish(completed)
    }
}
