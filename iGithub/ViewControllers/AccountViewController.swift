//
//  AccountViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 30/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    
    @IBOutlet private var header: UserHeaderView!
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        header.setContent(withUser: AccountManager.currentUser!)
        sizeHeaderToFit(tableView: self.tableView)
        
        AccountManager.refresh {
            self.header.setContent(withUser: $0)
            self.sizeHeaderToFit(tableView: self.tableView)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3, 4:
            return super.tableView(tableView, heightForHeaderInSection: section)
        default:
            return 25
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let repoTVC = RepositoryTableViewController()
            repoTVC.hidesBottomBarWhenPushed = true
            
            switch indexPath.row {
            case 0:
                repoTVC.viewModel = RepositoryTableViewModel(stargazer: AccountManager.currentUser!)
            case 1:
                repoTVC.viewModel = RepositoryTableViewModel(subscriber: AccountManager.currentUser!)
            default:
                break
            }
            navigationController?.pushViewController(repoTVC, animated: true)
        case 1:
            let gistTVC = GistTableViewController()
            gistTVC.hidesBottomBarWhenPushed = true

            switch indexPath.row {
            case 0:
                gistTVC.viewModel = GistTableViewModel(user: AccountManager.currentUser!.login!)
            case 1:
                gistTVC.viewModel = GistTableViewModel()
            default:
                break
            }
            navigationController?.pushViewController(gistTVC, animated: true)
        case 4:
            let alertController = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .actionSheet)
            
            let logoutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
                AccountManager.logout()
                
                let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
                UIApplication.shared.delegate!.window!!.rootViewController = loginVC
            }
            
            alertController.addAction(logoutAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
            self.navigationController?.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension AccountViewController: UserHeaderViewProtocol {
    
    func didTapFollowersButton() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followersOf: AccountManager.currentUser!)
        navigationController?.pushViewController(userTVC, animated: true)
    }
    
    func didTapRepositoiesButton() {
        let repoTVC = RepositoryTableViewController()
        repoTVC.viewModel = RepositoryTableViewModel(login: AccountManager.currentUser!.login, type: .user)
        navigationController?.pushViewController(repoTVC, animated: true)
    }
    
    func didTapFollowingButton() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followedBy: AccountManager.currentUser!)
        navigationController?.pushViewController(userTVC, animated: true)
    }
}
