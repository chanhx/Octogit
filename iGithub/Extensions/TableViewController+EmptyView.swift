//
//  TableViewController+EmptyView.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import StatusProvider

extension IssueTableViewController: StatusProvider {

    var emptyView: EmptyStatusDisplaying? {
        let image = Octicon.issueOpened.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any \(viewModel.state) issues.", caption: nil, image: image)
    }
}

extension PullRequestTableViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying? {
        let image = Octicon.gitPullrequest.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any \(viewModel.state) pull reqeusts.", caption: nil, image: image)
    }
}

extension RepositoryTableViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying? {
        let image = Octicon.repo.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any repositories.", caption: nil, image: image)
    }
}

extension ReleaseTableViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying? {
        let image = Octicon.tag.image(color: UIColor(netHex: 0xaaaaaa), iconSize: 50, size: CGSize(width: 50, height: 50))
        return EmptyStatusView(title: "There aren’t any releases.", caption: nil, image: image)
    }
}

extension UserTableViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying? {
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
