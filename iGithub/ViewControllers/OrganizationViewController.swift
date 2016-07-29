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
    
    var viewModel: OrganizationViewModel! {
        didSet {
            viewModel.user.asObservable()
                .subscribeNext { org in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        
                        self.avatarView.setAvatarWithURL(org.avatarURL)
                        self.nameLabel.text = org.name ?? (org.login ?? "")
                        self.descLabel.text = org.orgDescription
                        
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        guard viewModel.userLoaded else {
            return cell
        }
        
        switch (indexPath.section, viewModel.details.count) {
        case (0, 0), (1, 1...4):
            
            cell.accessoryType = .DisclosureIndicator
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Public activity"
            case 1:
                cell.textLabel?.text = "Repositories"
            case 2:
                cell.textLabel?.text = "Members"
            default:
                break
            }
            
            return cell
        case (0, 1...4):
            switch viewModel.details[indexPath.row] {
            case .Company:
                cell.textLabel?.text = "Company     \(viewModel.user.value.company!)"
            case .Location:
                cell.textLabel?.text = "Location    \(viewModel.user.value.location!)"
            case .Email:
                cell.textLabel?.text = "Email       \(viewModel.user.value.email!)"
            case .Blog:
                cell.textLabel?.text = "Blog        \(viewModel.user.value.blog!)"
            }
            
            return cell
        default:
            return cell
        }
    }

}
