//
//  AccountViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 30/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 3, 4:
            return super.tableView(tableView, heightForHeaderInSection: section)
        default:
            return 25
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = AccountManager.currentUser!
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let repoTVC = RepositoryTableViewController()
                repoTVC.hidesBottomBarWhenPushed = true
                repoTVC.viewModel = RepositoryTableViewModel(user: user)
                navigationController?.pushViewController(repoTVC, animated: true)
            case 1:
                let repoTVC = RepositoryTableViewController()
                repoTVC.hidesBottomBarWhenPushed = true
                repoTVC.viewModel = RepositoryTableViewModel.starred()
                navigationController?.pushViewController(repoTVC, animated: true)
            case 2:
                let repoTVC = RepositoryTableViewController()
                repoTVC.hidesBottomBarWhenPushed = true
                repoTVC.viewModel = RepositoryTableViewModel.subscribed()
                navigationController?.pushViewController(repoTVC, animated: true)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                let gistTVC = GistTableViewController()
                gistTVC.viewModel = GistTableViewModel(user: AccountManager.currentUser!.login!)
                navigationController?.pushViewController(gistTVC, animated: true)
            case 1:
                let gistTVC = GistTableViewController()
                gistTVC.viewModel = GistTableViewModel()
                navigationController?.pushViewController(gistTVC, animated: true)
            default:
                break
            }
        case 4:
            AccountManager.logout()
            
            let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.delegate!.window!!.rootViewController = loginVC
        default:
            break
        }
    }
}
