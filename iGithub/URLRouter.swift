//
//  URLRouter.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/10/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

struct URLRouter {
    
    static func viewController(forURL url: URL) -> UIViewController {
        
        return nativeViewController(forURL: url) ?? WebViewController(url: url)
    }
    
    static func nativeViewController(forURL url: URL) -> UIViewController? {
        
        if url.isGithubURL {
            return viewController(forGitHubURL: url)
//        } if url.isGistURL {
        }
        
        return nil
    }
    
    fileprivate static func viewController(forGitHubURL url: URL) -> UIViewController? {
        
        let pathComponents = url.pathComponents
        
        if pathComponents.count == 2 {
            let userVC = UserViewController.instantiateFromStoryboard()
            userVC.viewModel = UserViewModel(pathComponents[1])
            return userVC
        } else if pathComponents.count >= 3 {
            
            let owner = pathComponents[1]
            let name = pathComponents[2]
            let repo = "\(owner)/\(name)"
            
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
            } else if pathComponents.count == 5 && pathComponents[3] == "issues" {
                
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let issueVC = IssueViewController()
                issueVC.hidesBottomBarWhenPushed = true
                issueVC.viewModel = IssueViewModel(owner: owner, name: name, number: number)
                
                return issueVC
                
            } else if pathComponents.count == 5 && pathComponents[3] == "pull" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let pullVC = PullRequestViewController()
                pullVC.hidesBottomBarWhenPushed = true
                pullVC.viewModel = PullRequestViewModel(owner: owner, name: name, number: number)
                
                return pullVC

//            } else if pathComponents.count == 5 && pathComponents[3] == "commit" {
//                let commitVC = CommitTableViewController()
//                commitVC.viewModel = CommitViewModel(repo: repo, commit: <#T##Commit#>)
//                
//                return commitVC
            } else if pathComponents.count == 6 && pathComponents[3] == "pull" && pathComponents[5] == "commits" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = CommitTableViewModel(repo: repo, pullRequestNumber: number)
                return commitTVC
            } else if pathComponents.count == 6 && pathComponents[3] == "pull" && pathComponents[5] == "files" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let fileTVC = CommitFileTableViewController()
                fileTVC.viewModel = CommitFileTableViewModel(repo: repo, pullRequestNumber: number)
                return fileTVC
            }
        }
        
        return nil
    }
}
