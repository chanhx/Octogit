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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        self.selectionStyle = .None
        
        webView.scrollView.scrollEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func layout() {
        
        contentView.addSubview(webView)
        let margins = contentView.layoutMarginsGuide
        
        webView.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
        webView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true
        webView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        webView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
    }
    
}
