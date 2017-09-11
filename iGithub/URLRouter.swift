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
        
        let vc = nativeViewController(forURL: url) ?? WebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        
        return vc
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
        let len = pathComponents.count
        
        if len == 2 {
            let userVC = UserViewController.instantiateFromStoryboard()
            userVC.viewModel = UserViewModel(pathComponents[1])
            return userVC
        } else if len >= 3 {
            
            let owner = pathComponents[1]
            let name = pathComponents[2]
            let repo = "\(owner)/\(name)"
            
            if len == 3 {
                let repoVC = RepositoryViewController.instantiateFromStoryboard()
                repoVC.viewModel = RepositoryViewModel(repo: repo)
                return repoVC
            } else if len == 4 && pathComponents[3] == "issues" {
                let issueTVC = IssueTableViewController()
                issueTVC.viewModel = IssueTableViewModel(repo: repo)
                return issueTVC
            } else if len == 4 && pathComponents[3] == "pulls" {
                let pullTVC = PullRequestTableViewController()
                pullTVC.viewModel = PullRequestTableViewModel(repo: repo)
                return pullTVC
            } else if len == 4 && pathComponents[3] == "commits" {
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = CommitTableViewModel(repo: repo, branch: pathComponents[4])
                return commitTVC
            } else if len == 5 && pathComponents[3] == "issues" {
                
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let issueVC = IssueViewController()
                issueVC.viewModel = IssueViewModel(owner: owner, name: name, number: number)
                
                return issueVC
                
            } else if len == 5 && pathComponents[3] == "pull" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let pullVC = PullRequestViewController()
                pullVC.viewModel = PullRequestViewModel(owner: owner, name: name, number: number)
                
                return pullVC

//            } else if len == 5 && pathComponents[3] == "commit" {
//                let commitVC = CommitTableViewController()
//                commitVC.viewModel = CommitViewModel(repo: repo, commit: <#T##Commit#>)
//                
//                return commitVC
            } else if len == 5 && pathComponents[3] == "tree" {
                let ref = pathComponents[4]
                let fileTVC = FileTableViewController()
                fileTVC.viewModel = FileTableViewModel(repository: repo, ref: ref)
                
                return fileTVC
            } else if len == 6 && pathComponents[3] == "pull" && pathComponents[5] == "commits" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = CommitTableViewModel(repo: repo, pullRequestNumber: number)
                return commitTVC
            } else if len == 6 && pathComponents[3] == "pull" && pathComponents[5] == "files" {
                guard let number = Int(pathComponents[4]) else {
                    return nil
                }
                let fileTVC = CommitFileTableViewController()
                fileTVC.viewModel = CommitFileTableViewModel(repo: repo, pullRequestNumber: number)
                return fileTVC
            } else if len >= 6 && pathComponents[3] == "tree" {
                let ref = pathComponents[4]
                let path = pathComponents.suffix(len-5).joined(separator: "/")
                let fileTVC = FileTableViewController()
                fileTVC.viewModel = FileTableViewModel(repository: repo, path: path, ref: ref)
                
                return fileTVC
            }
        }
        
        return nil
    }
}
