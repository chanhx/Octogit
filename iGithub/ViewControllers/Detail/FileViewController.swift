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
    
    let titleLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = UIColor.white
        return $0
    } (UILabel())
    
    var viewModel: FileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        self.show(indicator: indicator, onView: webView)
        
        navigationItem.titleView = titleLabel
        setTitle()
		
        viewModel.html.asDriver()
            .filter { $0.count > 0 }
            .drive(onNext: { [unowned self] html in
                self.indicator.removeFromSuperview()
                self.webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.contentData.asDriver()
            .filter { $0.count > 0 }
            .drive(onNext: { [unowned self] data in
                self.indicator.removeFromSuperview()
                self.webView.load(data, mimeType: self.viewModel.mimeType, characterEncodingName: "utf-8", baseURL: Bundle.main.resourceURL!)
            })
            .disposed(by: viewModel.disposeBag)

        viewModel.getFileContent()
    }
    
    private func setTitle()  {
        
        let attributedTitle = NSMutableAttributedString(string: viewModel.fileName)
        
        if let path = viewModel.filePath, path.count > 0 {
            attributedTitle.append(NSAttributedString(string: "\n\(path)",
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11)]))
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 10
        attributedTitle.addAttributes(
            [NSAttributedString.Key.paragraphStyle : paragraphStyle],
            range: NSRangeFromString(attributedTitle.string))
        
        titleLabel.attributedText = attributedTitle
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
