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
    
    enum SectionType {
        case Content
        case Asignee
        case Milestone
    }

    var issue: Issue
    var contentHeight = Variable<CGFloat>(0)
    var sections = [SectionType]()
    
    init(issue: Issue) {
        self.issue = issue
        super.init()
    }
    
    var numberOfSections: Int {
        var sections = 0
        if issue.body?.characters.count > 0 {
            sections += 1
        }
        
        return sections
    }
    
    
    var contentHTML: String {
        let template = try! Template(named: "issue")
        
        let data = ["content": issue.body!]
        
        return try! template.render(Box(data))
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        contentHeight.value = webView.scrollView.contentSize.height + 16
    }
}
