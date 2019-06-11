//
//  WebViewCell.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/2/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit

class WebViewCell: UITableViewCell {

    let webView = WKWebView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configure()
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.configure()
        self.layout()
    }
    
    func configure() {
        self.selectionStyle = .none
        
        webView.scrollView.isScrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func layout() {
        contentView.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}
