//
//  OrganizationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class OrganizationViewController: BaseTableViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let statusCell = StatusCell(name: "organizations")
    
    var viewModel: OrganizationViewModel! {
        didSet {
            viewModel.user.asObservable()
                .subscribe(onNext: { org in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        self.avatarView.setAvatarWithURL(org.avatarURL)
                        self.nameLabel.text = org.name ?? (org.login ?? "")
                        self.descLabel.text = org.orgDescription
                        
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
        case (0, 0), (1, 1...4):
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = ["Public activity", "Repositories", "Members"][(indexPath as NSIndexPath).row]
            
            return cell
        case (0, 1...4):
            switch viewModel.details[(indexPath as NSIndexPath).row] {
            case .company:
                cell.textLabel?.text = "Company     \(viewModel.user.value.company!)"
            case .location:
                cell.textLabel?.text = "Location    \(viewModel.user.value.location!)"
            case .email:
                cell.textLabel?.text = "Email       \(viewModel.user.value.email!)"
            case .blog:
                cell.textLabel?.text = "Blog        \(viewModel.user.value.blog!)"
            }
            
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch ((indexPath as NSIndexPath).section, viewModel.details.count) {
        case (0, 0), (1, 1...4):
            
            switch (indexPath as NSIndexPath).row {
            case 0:
                let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventTVC") as! EventTableViewController
                eventTVC.viewModel = EventTableViewModel(org: viewModel.user.value)
                self.navigationController?.pushViewController(eventTVC, animated: true)
            case 1:
                let repositoryTVC = RepositoryTableViewController()
                repositoryTVC.viewModel = RepositoryTableViewModel(organization: viewModel.user.value)
                self.navigationController?.pushViewController(repositoryTVC, animated: true)
            case 2:
                let userTVC = UserTableViewController()
                userTVC.viewModel = UserTableViewModel(organization: viewModel.user.value)
                self.navigationController?.pushViewController(userTVC, animated: true)
            default:
                break
            }
        default:
            return
        }
    }

}
