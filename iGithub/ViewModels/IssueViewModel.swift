//
//  IssueViewModel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import WebKit
import Mustache
import RxSwift

class IssueViewModel: NSObject, WKNavigationDelegate {
    
    enum ContentType {
        case body
        case label
        case milestone
    }

    var issue: Issue
    var contentHeight = Variable<CGFloat>(0)
    var contentTypes = [ContentType]()
    
    init(issue: Issue) {
        self.issue = issue
        
        if let count = issue.body?.characters.count, count > 0 {
            contentTypes.append(.body)
        }
        if let count = issue.labels?.count, count > 0 {
            contentTypes.append(.label)
        }
        if issue.milestone != nil {
            contentTypes.append(.milestone)
        }
        
        super.init()
    }
    
    var numberOfSections: Int {
        if let count = issue.assignees?.count, count > 0 {
            return contentTypes.count > 0 ? 2 : 1
        } else {
            return contentTypes.count > 0 ? 1 : 0
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            if contentTypes.count > 0 {
                return contentTypes.count
            } else {
                return issue.assignees!.count
            }
        case 1:
            return issue.assignees!.count
        default:
            return 0
        }
    }
    
    var contentHTML: String {
        let template = try! Template(named: "issue")
        
        let data = ["content": issue.body!]
        
        return try! template.render(Box(data))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentHeight.value = webView.scrollView.contentSize.height
    }
}
