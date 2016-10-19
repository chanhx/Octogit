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
            let userVC = UserViewController.instantiateFromStoryboard()
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
                let repoVC = RepositoryViewController.instantiateFromStoryboard()
                repoVC.viewModel = RepositoryViewModel(repo: repo)
                return repoVC
            } else if pathComponents.count == 4 && pathComponents[3] == "issues" {
                let issueTVC = IssueTableViewController()
                issueTVC.viewModel = IssueTableViewModel(repo: repo)
                return issueTVC
            } else if pathComponents.count == 4 && pathComponents[3] == "pulls" {
                let pullTVC = PullRequestTableViewController()
                pullTVC.viewModel = PullRequestTableViewModel(repo: repo)
                return pullTVC
            } else if pathComponents.count == 4 && pathComponents[3] == "commits" {
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = CommitTableViewModel(repo: repo, branch: pathComponents[4])
                return commitTVC
//            } else if pathComponents.count == 5 && pathComponents[3] == "issues" {
//                let issueVC = IssueViewController.instantiateFromStoryboard()
//                let issue = Issue(
//                issueVC.viewModel = IssueViewModel(
//            } else if pathComponents.count == 5 && pathComponents[3] == "pull" {
//                let pullVC = IssueViewController.instantiateFromStoryboard()
//                
//            } else if pathComponents.count == 5 && pathComponents[3] == "commit" {
//                let commitVC = CommitViewController.instantiateFromStoryboard()
//                commitVC.viewModel = CommitViewModel(repo: repo, commit: <#T##Commit#>)
//                
//                return commitVC
//            } else if pathComponents.count >= 4 {
//                TODO
            }
        }
        
        return WebViewController(url: url)
    }
}
