//
//  TableViewController+EmptyView.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension IssueTableViewController: StatusProvider {

    var emptyView: UIView? {
        let image = Octicon.issueOpened.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any \(viewModel.state) issues", image: image)
    }
}

extension PullRequestTableViewController: StatusProvider {
    
    var emptyView: UIView? {
        let image = Octicon.gitPullrequest.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any \(viewModel.state) pull reqeusts", image: image)
    }
}

extension RepositoryTableViewController: StatusProvider {
    
    var emptyView: UIView? {
        let image = Octicon.repo.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any repositories", image: image)
    }
}

extension ReleaseTableViewController: StatusProvider {
    
    var emptyView: UIView? {
        let image = Octicon.tag.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any releases", image: image)
    }
}

extension UserTableViewController: StatusProvider {
    
    var emptyView: UIView? {
        var title: String?
        
        switch viewModel.token {
        case .organizationMembers:
            title = "No Members"
        case .followedBy:
            title = "No following users"
        case .followersOf:
            title = "No followers"
        default:
            break
        }
        return EmptyStatusView(title: title, caption: nil)
    }
}

extension ExplorationViewController: StatusProvider {
    
    var loadingView: UIView? {
        let loadingView = UIView()
        loadingView.backgroundColor = .white
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            loadingView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 180)
        ])
        
        let indicator = LoadingIndicator(strokeEnd: 0.95)
        let border = UIView()
        border.backgroundColor = UIColor(netHex: 0xDDDDDD)
        
        loadingView.addSubviews([indicator, border])
        
        
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20),
            indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 26),
            indicator.widthAnchor.constraint(equalToConstant: 26),
            
            border.widthAnchor.constraint(equalTo: loadingView.widthAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor)
        ])
        
        indicator.startAnimating()
        
        return loadingView
    }
    
    var emptyView: UIView? {
        let emptyView = UIView()
        emptyView.backgroundColor = .white
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            emptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 180)
        ])
        
        let label: UILabel = {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let border: UIView = {
            $0.backgroundColor = UIColor(netHex: 0xDDDDDD)
            return $0
        }(UIView())
        
        emptyView.addSubviews([label, border])
        
        let margins = emptyView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 35),
            label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -30),
            
            border.widthAnchor.constraint(equalTo: emptyView.widthAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
        ])
        
        switch viewModel.type {
        case .repositories:
            label.text = viewModel.repoTVM.message
        case .users:
            label.text = viewModel.userTVM.message
        }
        
        return emptyView
    }
}

extension SearchViewController: StatusProvider {
    
    var loadingView: UIView? {
        let loadingView = UIView()
        loadingView.backgroundColor = .white
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            loadingView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 180)
            ])
        
        let indicator = LoadingIndicator(strokeEnd: 0.95)
        let border = UIView()
        border.backgroundColor = UIColor(netHex: 0xDDDDDD)
        
        loadingView.addSubviews([indicator, border])
        
        
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20),
            indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 26),
            indicator.widthAnchor.constraint(equalToConstant: 26),
            
            border.widthAnchor.constraint(equalTo: loadingView.widthAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor)
            ])
        
        indicator.startAnimating()
        
        return loadingView
    }
    
    var emptyView: UIView? {
        let emptyView = UIView()
        emptyView.backgroundColor = .white
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            emptyView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 180)
            ])
        
        let label: UILabel = {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
            $0.textColor = UIColor.black
            $0.textAlignment = .center
            return $0
        }(UILabel())
        
        let border: UIView = {
            $0.backgroundColor = UIColor(netHex: 0xDDDDDD)
            return $0
        }(UIView())
        
        emptyView.addSubviews([label, border])
        
        let margins = emptyView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 35),
            label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -30),
            
            border.widthAnchor.constraint(equalTo: emptyView.widthAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
            ])
        
        switch viewModel.searchObject {
        case .repository:
            if let query = viewModel.repoTVM.query {
                label.text = "No repositories matching '\(query)'"
            } else {
                label.text = ""
            }
        case .user:
            if let query = viewModel.userTVM.query {
                label.text = "No users matching '\(query)'"
            } else {
                label.text = ""
            }
        }
        
        return emptyView
    }
}

