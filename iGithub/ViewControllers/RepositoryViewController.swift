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
            let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryLoadingCell", forIndexPath: indexPath) as! LoadingStatusCell
            cell.indicator.startAnimating()
            return cell
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
                cell.entity = viewModel.repository.value.owner
                cell.accessoryType = .DisclosureIndicator
                
                return cell
            default:
                let cell = UITableViewCell()
                cell.accessoryType = .None
                cell.selectionStyle = .None
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .ByWordWrapping
                cell.textLabel?.text = viewModel.repository.value.repoDescription!
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryInfoCell", forIndexPath: indexPath)
            cell.textLabel?.font = UIFont(name: "octicons", size: 18)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "\(Octicon.IssueOpened) Issues"
            case 1:
                cell.textLabel?.text = "\(Octicon.Tag) Releases"
            case 2:
                cell.textLabel?.text = "\(Octicon.Rss) Recent Activity"
            case 3:
                cell.textLabel?.text = "\(Octicon.Organization) Contributors"
            case 4:
                cell.textLabel?.text = "\(Octicon.GitPullRequest) Pull Requests"
            default: break
            }
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = indexPath.row == 0 ? "Code" : "Commmits"
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        if (indexPath.section, indexPath.row) == (0, 0) {
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
        }
        
        else if (indexPath.section, indexPath.row) == (2, 0) {
            let filesTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FileTVC") as! FilesViewController
            filesTableVC.viewModel = viewModel.filesTableViewModel
            self.navigationController?.pushViewController(filesTableVC, animated: true)
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
