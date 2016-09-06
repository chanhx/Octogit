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
        case Body
        case Label
        case Milestone
    }

    var issue: Issue
    var contentHeight = Variable<CGFloat>(0)
    var contentTypes = [ContentType]()
    
    init(issue: Issue) {
        self.issue = issue
        
        if issue.body?.characters.count > 0 {
            contentTypes.append(.Body)
        }
        if issue.labels?.count > 0 {
            contentTypes.append(.Label)
        }
        if issue.milestone != nil {
            contentTypes.append(.Milestone)
        }
        
        super.init()
    }
    
    var numberOfSections: Int {
        if issue.assignees?.count > 0 {
            return contentTypes.count > 0 ? 2 : 1
        } else {
            return contentTypes.count > 0 ? 1 : 0
        }
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
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
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        contentHeight.value = webView.scrollView.contentSize.height
    }
}
