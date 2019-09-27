//
//  UserViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UserViewController: BaseTableViewController {
    
    @IBOutlet weak var header: UserHeaderView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var statusCell = StatusCell(name: "user")
    
    var viewModel: UserViewModel! {
        didSet {
            let userDriver = viewModel.user.asDriver()
            let orgsDriver = viewModel.organizations.asDriver()
            let isFollowingDriver = viewModel.isFollowing.asDriver()
            
            userDriver.drive(onNext: { [unowned self] user in
                    self.tableView.reloadData()
                
                    self.configureHeader(user: user)
                    self.sizeHeaderToFit(tableView: self.tableView)
                })
                .disposed(by: viewModel.disposeBag)
            
            Driver.combineLatest(userDriver, orgsDriver) { user, orgs in
                    (user, orgs)
                }
                .filter { (user, orgs) in
                    user.followers != nil && orgs.count > 0
                }
                .drive(onNext: { [unowned self] _ in
                    self.tableView.reloadData()
                })
                .disposed(by: viewModel.disposeBag)
            
            Driver.combineLatest(userDriver, isFollowingDriver) { user, isFollowing in
                    (user, isFollowing)
                }
                .filter { (user, isFollowing) in
                    user.followers != nil && isFollowing != nil
                }
                .drive(onNext: { [unowned self] _ in
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                })
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    class func instantiateFromStoryboard() -> UserViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.viewModel.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionSheet))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.header.delegate = self
        
        if !viewModel.userLoaded {
            self.viewModel.fetchUser()
        }
        self.viewModel.checkIsFollowing()
        self.viewModel.fetchOrganizations()
    }
    
    func configureHeader(user: User) {
        self.header.setContent(withUser: user)
        self.bioLabel.text = user.bio
        self.bioLabel.isHidden = user.bio == nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard viewModel.userLoaded else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
        
        switch viewModel.sectionTypes[section] {
        case .organizations:
            return 25
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsIn(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == viewModel.numberOfSections - 1 && viewModel.organizations.value.count > 0 {
            return "Organizations"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard viewModel.userLoaded else {
            return statusCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.textColor = UIColor(netHex: 0x333333)
        
        switch viewModel.sectionTypes[indexPath.section] {
        case .vcards:
            switch viewModel.vcardDetails[indexPath.row] {
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
        case .general:
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
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
        case .organizations:
            let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            userCell.entity = viewModel.organizations.value[indexPath.row]
            return userCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch viewModel.sectionTypes[indexPath.section] {
        case .vcards:
            if viewModel.vcardDetails[indexPath.row] == .blog {
                navigationController?.pushViewController(URLRouter.viewController(forURL: viewModel.user.value.blog!), animated: true)
            }
        case .general:
            switch indexPath.row {
            case 0:
                let eventTVC = EventTableViewController()
                eventTVC.viewModel = EventTableViewModel(user: viewModel.user.value, type: .performed)
                navigationController?.pushViewController(eventTVC, animated: true)
            case 1:
                let repositoryTVC = RepositoryTableViewController()
                repositoryTVC.viewModel = RepositoryTableViewModel(stargazer: viewModel.user.value)
                navigationController?.pushViewController(repositoryTVC, animated: true)
            case 2:
                let gistTVC = GistTableViewController()
                gistTVC.viewModel = GistTableViewModel(user: viewModel.user.value.login!)
                navigationController?.pushViewController(gistTVC, animated: true)
            default:
                break
            }
        case .organizations:
            let orgVC = OrganizationViewController.instantiateFromStoryboard()
            let organization = self.viewModel.organizations.value[indexPath.row]
            orgVC.viewModel = OrganizationViewModel(organization)
            self.navigationController?.pushViewController(orgVC, animated: true)
        }
    }
}

extension UserViewController: UserHeaderViewProtocol {
    
    func didTapFollowersButton() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followersOf: viewModel.user.value)
        navigationController?.pushViewController(userTVC, animated: true)
    }
    
    func didTapRepositoiesButton() {
        let repoTVC = RepositoryTableViewController()
        repoTVC.viewModel = RepositoryTableViewModel(login: viewModel.user.value.login, type: .user)
        navigationController?.pushViewController(repoTVC, animated: true)
    }
    
    func didTapFollowingButton() {
        let userTVC = UserTableViewController()
        userTVC.viewModel = UserTableViewModel(followedBy: viewModel.user.value)
        navigationController?.pushViewController(userTVC, animated: true)
    }
}

extension UserViewController {
    
    var alertController: UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { _ in
            let items: [Any] = [
                self.viewModel.information,
                self.viewModel.htmlURL
            ]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.navigationController?.present(activityVC, animated: true, completion: nil)
            
        })
        let followAction = UIAlertAction(title: viewModel.isFollowing.value! ? "Unfollow" : "Follow", style: .default, handler: { _ in
            self.viewModel.toggleFollowing()
        })
        let copyURLAction = UIAlertAction(title: "Copy URL", style: .default, handler: { _ in
            UIPasteboard.general.string = self.viewModel.htmlURL.absoluteString
        })
        let showOnGithubAction = UIAlertAction(title: "Show on GitHub", style: .default, handler: { _ in
            let webVC = WebViewController(url: self.viewModel.htmlURL)
            webVC.showNativeController = false
            self.navigationController?.pushViewController(webVC, animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if viewModel.user.value.id! != AccountManager.currentUser!.id! {
            alertController.addAction(followAction)
        }
        alertController.addAction(shareAction)
        alertController.addAction(copyURLAction)
        alertController.addAction(showOnGithubAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    @objc func showActionSheet() {
        self.present(alertController, animated: true, completion: nil)
    }
}
