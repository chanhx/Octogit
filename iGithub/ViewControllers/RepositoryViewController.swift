//
//  RepositoryViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/23/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftDate

class RepositoryViewController: BaseTableViewController {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    
    let statusCell = StatusCell(name: "repository")
    
    var viewModel: RepositoryViewModel! {
        didSet {
            viewModel.repository.asObservable().subscribeNext { repo in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    
                    if self.viewModel.repositoryLoaded {
                        if repo.isPrivate! {
                            self.iconLabel.text = Octicon.Lock.rawValue
                        } else {
                            self.iconLabel.text = repo.isAFork! ? Octicon.RepoForked.rawValue : Octicon.Repo.rawValue
                        }
                        self.updateTimeLabel.text = "Latest commit \(repo.pushedAt!.naturalString)"
                    } else {
                        self.iconLabel.text = ""
                    }
                    self.titleLabel.text = repo.name
                    
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
            }.addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchRepository()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard viewModel.repositoryLoaded else {
            return statusCell
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
                cell.entity = viewModel.repository.value.owner
                cell.accessoryType = .DisclosureIndicator
                
                return cell
            case viewModel.numberOfRowsInSection(0) - 1:
                let cell = UITableViewCell()
                cell.accessoryType = .DisclosureIndicator
                cell.textLabel?.attributedText = Octicon.Book.iconString(" README", iconSize: 18, iconColor: .grayColor())
                return cell
            default:
                let cell = UITableViewCell()
                cell.selectionStyle = .None
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .ByWordWrapping
                cell.textLabel?.text = viewModel.repository.value.repoDescription!
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryInfoCell", forIndexPath: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.IssueOpened.iconString(" Issues", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 1:
                cell.textLabel?.attributedText = Octicon.Tag.iconString(" Releases", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 2:
                cell.textLabel?.attributedText = Octicon.Rss.iconString(" Recent Activity", iconSize: 18, iconColor: .grayColor())
            case 3:
                cell.textLabel?.attributedText = Octicon.Organization.iconString(" Contributors", iconSize: 18, iconColor: .lightGrayColor())
            case 4:
                cell.textLabel?.attributedText = Octicon.GitPullRequest.iconString(" Pull Requests", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            default: break
            }
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.accessoryType = .DisclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.Code.iconString(" Code", iconSize: 18, iconColor: .lightGrayColor())
            case 1:
                cell.textLabel?.attributedText = Octicon.GitCommit.iconString(" Commits", iconSize: 18, iconColor: .lightGrayColor())
            default:
                break
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            var vc: UIViewController
            
            switch viewModel.repository.value.owner!.type! {
            case .User:
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserVC")
                (vc as! UserViewController).viewModel = self.viewModel.ownerViewModel
            case .Organization:
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrgVC")
                (vc as! OrganizationViewController).viewModel = (self.viewModel.ownerViewModel as! OrganizationViewModel)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case (1, 0):
            let issueTVC = IssueTableViewController()
            issueTVC.viewModel = IssueTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(issueTVC, animated: true)
        case (1, 2):
            let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventTVC") as! EventTableViewController
            eventTVC.viewModel = EventTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(eventTVC, animated: true)
        case (1, 3):
            let memberTVC = UserTableViewController()
            memberTVC.viewModel = UserTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(memberTVC, animated: true)
        case (2, 0):
            let fileTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FileTVC") as! FileTableViewController
            fileTableVC.viewModel = viewModel.filesTableViewModel
            self.navigationController?.pushViewController(fileTableVC, animated: true)
        default:
            break
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
