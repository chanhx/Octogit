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
            switch viewModel.token {
            case .Members:
                statusCell = StatusCell(name: "members")
            default:
                statusCell = StatusCell(name: "users")
            }
            
            viewModel.user.asObservable()
                .subscribeNext { user in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        
                        self.avatarView.setAvatarWithURL(user.avatarURL)
                        self.nameLabel.text = user.name ?? (user.login ?? "")
                        self.followersButton.setTitle(user.followers, title: "Followers")
                        self.repositoriesButton.setTitle(user.publicRepos, title: "Repositories")
                        self.followingButton.setTitle(user.following, title: "Following")
                        if let bio = user.bio {
                            self.bioLabel.text = bio
                            self.bioLabel.hidden = false
                        } else {
                            self.bioLabel.hidden = true
                        }
                        
                        if let headerView = self.tableView.tableHeaderView {
                            let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                            var frame = headerView.frame
                            frame.size.height = height
                            headerView.frame = frame
                            self.tableView.tableHeaderView = headerView
                            headerView.setNeedsLayout()
                            headerView.layoutIfNeeded()
                        }
                    }
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.viewModel.title
        
        self.viewModel.fetchUser()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard viewModel.userLoaded else {
            return statusCell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        switch (indexPath.section, viewModel.details.count) {
        case (0, 0), (1, 1...4):
            cell.accessoryType = .DisclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.Rss.iconString(" Public activity", iconSize: 18, iconColor: .lightGrayColor())
            case 1:
                cell.textLabel?.attributedText = Octicon.Star.iconString(" Starrd repositories", iconSize: 18, iconColor: .lightGrayColor())
            case 2:
                cell.textLabel?.attributedText = Octicon.Gist.iconString(" Gitsts", iconSize: 18, iconColor: .lightGrayColor())
            default:
                break
            }
            
            return cell
        case (0, 1...4):
            switch viewModel.details[indexPath.row] {
            case .Company:
                cell.textLabel?.attributedText = Octicon.Organization.iconString(" \(viewModel.user.value.company!)", iconSize: 18, iconColor: .lightGrayColor())
            case .Location:
                cell.textLabel?.attributedText = Octicon.Location.iconString(" \(viewModel.user.value.location!)", iconSize: 18, iconColor: .lightGrayColor())
            case .Email:
                cell.textLabel?.attributedText = Octicon.Mail.iconString(" \(viewModel.user.value.email!)", iconSize: 18, iconColor: .lightGrayColor())
            case .Blog:
                cell.textLabel?.attributedText = Octicon.Link.iconString(" \(viewModel.user.value.blog!)", iconSize: 18, iconColor: .lightGrayColor())
                cell.accessoryType = .DisclosureIndicator
            }
            
            return cell
        case (1, 0), (2, _):
            cell.textLabel?.text = "Organization"
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        switch (indexPath.section, viewModel.details.count) {
        case (0, 1...4):
            switch viewModel.details[indexPath.row] {
            case .Blog:
                navigationController?.pushViewController(URLRouter.viewControllerForURL(viewModel.user.value.blog!), animated: true)
            default:
                break
            }
        case (0, 0), (1, 1...4):
            switch indexPath.row {
            case 0:
                let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventTVC") as! EventTableViewController
                eventTVC.viewModel = EventTableViewModel(user: viewModel.user.value, type: .Performed)
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
