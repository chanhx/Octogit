//
//  UserViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class UserViewController: BaseTableViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followersButton: CountButton!
    @IBOutlet weak var followingButton: CountButton!
    @IBOutlet weak var repositoriesButton: CountButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var statusCell: StatusCell!
    
    var viewModel: UserViewModel! {
        didSet {
            statusCell = StatusCell(name: "user")
            
            viewModel.user.asObservable()
                .subscribe(onNext: { user in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        self.avatarView.setAvatarWithURL(user.avatarURL)
                        self.nameLabel.text = user.name ?? user.login
                        self.followersButton.setTitle(user.followers, title: "Followers")
                        self.repositoriesButton.setTitle(user.publicRepos, title: "Repositories")
                        self.followingButton.setTitle(user.following, title: "Following")
                        self.bioLabel.text = user.bio
                        self.bioLabel.isHidden = user.bio == nil
                        
                        if let headerView = self.tableView.tableHeaderView {
                            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                            var frame = headerView.frame
                            frame.size.height = height
                            headerView.frame = frame
                            self.tableView.tableHeaderView = headerView
                            headerView.setNeedsLayout()
                            headerView.layoutIfNeeded()
                        }
                    }
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.viewModel.title
        
        self.viewModel.fetchUser()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard viewModel.userLoaded else {
            return statusCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        switch ((indexPath as NSIndexPath).section, viewModel.details.count) {
        case (0, 1...4):
            switch viewModel.details[(indexPath as NSIndexPath).row] {
            case .company:
                cell.textLabel?.attributedText = Octicon.organization.iconString(" \(viewModel.user.value.company!)", iconSize: 18, iconColor: .lightGray)
            case .location:
                cell.textLabel?.attributedText = Octicon.location.iconString(" \(viewModel.user.value.location!)", iconSize: 18, iconColor: .lightGray)
            case .email:
                cell.textLabel?.attributedText = Octicon.mail.iconString(" \(viewModel.user.value.email!)", iconSize: 18, iconColor: .lightGray)
            case .blog:
                cell.textLabel?.attributedText = Octicon.link.iconString(" \(viewModel.user.value.blog!)", iconSize: 18, iconColor: .lightGray)
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        case (0, 0), (1, 1...4):
            cell.accessoryType = .disclosureIndicator
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.attributedText = Octicon.rss.iconString(" Public activity", iconSize: 18, iconColor: .lightGray)
            case 1:
                cell.textLabel?.attributedText = Octicon.star.iconString(" Starrd repositories", iconSize: 18, iconColor: .lightGray)
            case 2:
                cell.textLabel?.attributedText = Octicon.gist.iconString(" Gitsts", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }
            
            return cell
        case (1, 0), (2, _):
            cell.textLabel?.text = "Organization"
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch ((indexPath as NSIndexPath).section, viewModel.details.count) {
        case (0, 1...4):
            switch viewModel.details[(indexPath as NSIndexPath).row] {
            case .blog:
                navigationController?.pushViewController(URLRouter.viewControllerForURL(viewModel.user.value.blog!), animated: true)
            default:
                break
            }
        case (0, 0), (1, 1...4):
            switch (indexPath as NSIndexPath).row {
            case 0:
                let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventTVC") as! EventTableViewController
                eventTVC.viewModel = EventTableViewModel(user: viewModel.user.value, type: .performed)
                navigationController?.pushViewController(eventTVC, animated: true)
            case 1:
                let repositoryTVC = RepositoryTableViewController()
                repositoryTVC.viewModel = RepositoryTableViewModel(stargazer: viewModel.user.value)
                navigationController?.pushViewController(repositoryTVC, animated: true)
            default:
                break
            }
        case (1, 0), (2, _):
            break
        default:
            break
        }
    }
    
    @IBAction func showFollowers() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followersOf: viewModel.user.value)
        navigationController?.pushViewController(userTVC, animated: true)
    }
    
    @IBAction func showRepositories() {
        let repoTVC = RepositoryTableViewController()
        repoTVC.viewModel = RepositoryTableViewModel(user: viewModel.user.value)
        navigationController?.pushViewController(repoTVC, animated: true)
    }
    
    @IBAction func showFollowings() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followedBy: viewModel.user.value)
        navigationController?.pushViewController(userTVC, animated: true)
    }

}
