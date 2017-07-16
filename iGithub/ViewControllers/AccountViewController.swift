//
//  AccountViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 30/10/2016.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    
    private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.setAvatar(with: AccountManager.currentUser?.avatarURL)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)))
        
        navigationItem.title = AccountManager.currentUser?.login
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        AccountManager.refresh {
            if self.imageView.kf.webURL != $0.avatarURL {
                self.imageView.setAvatar(with: $0.avatarURL)
            }
            self.navigationItem.title = AccountManager.currentUser?.login
        }
    }
    
    func showProfile() {
        let userVC = UserViewController.instantiateFromStoryboard()
        userVC.viewModel = UserViewModel(AccountManager.currentUser!)
        navigationController?.pushViewController(userVC, animated: true)
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = AccountManager.currentUser!
        
        switch indexPath.section {
        case 0:
            let repoTVC = RepositoryTableViewController()
            repoTVC.hidesBottomBarWhenPushed = true
            
            switch indexPath.row {
            case 0:
                repoTVC.viewModel = RepositoryTableViewModel(user: user)
            case 1:
                repoTVC.viewModel = RepositoryTableViewModel.starred()
            case 2:
                repoTVC.viewModel = RepositoryTableViewModel.subscribed()
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
