//
//  URLRouter.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/10/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import ObjectMapper

struct URLRouter {
    static func viewControllerForURL(_ url: URL) -> UIViewController {
        if url.isGithubURL {
            return viewControllerForGithubURL(url)
        } else {
            return WebViewController(url: url)
        }
    }
    
    fileprivate static func viewControllerForGithubURL(_ url: URL) -> UIViewController {
        
        let pathComponents = url.pathComponents
        
        if pathComponents.count == 2 {
            let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserViewController
            userVC.viewModel = UserViewModel(pathComponents[1])
            return userVC
        } else if pathComponents.count >= 3 {
            
            let repo = Mapper<Repository>().map(JSON:
                [
                    "name": pathComponents[2],
                    "full_name": "\(pathComponents[1])/\(pathComponents[2])"
                ]
            )!
            
            if pathComponents.count == 3 {
                let repoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryVC") as! RepositoryViewController
                repoVC.viewModel = RepositoryViewModel(repo: repo)
                return repoVC
            } else if pathComponents.count == 4 && pathComponents[3] == "issues" {
                let issueTVC = IssueTableViewController()
                issueTVC.viewModel = IssueTableViewModel(repo: repo)
                return issueTVC
            } else if pathComponents.count == 4 && pathComponents[3] == "pull" {
                // TO DO
//            } else if pathComponents.count == 5 && pathComponents[4] == "issues" {
//                let issueVC = IssueViewController()
//                let issue = Issue(
//                issueVC.viewModel = IssueViewModel(
            }
        }
        
        return WebViewController(url: url)
    }
}
