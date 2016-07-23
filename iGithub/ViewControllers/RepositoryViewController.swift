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
                        self.iconLabel.text = repo.isAFork! ? Octicon.RepoForked.rawValue : Octicon.Repo.rawValue
                        
//                        let lastUpdatedTime = repo.updatedAt!.toNaturalString(NSDate(), style: FormatterStyle(style: .Full, max: 1))!
//                        self.updateTimeLabel.text = "last updated \(lastUpdatedTime) ago"
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
        return viewModel.repositoryLoaded ? 3 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard viewModel.repositoryLoaded else {
            return 1
        }
        
        switch section {
        case 0:
            return viewModel.repository.value.repoDescription != nil ? 2 : 1
        case 1:
            return 6
        default:
            return 1
        }
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
                let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryOwnerCell", forIndexPath: indexPath) as! RepositoryOwnerCell
                if viewModel.repository.value.owner != nil {
                    cell.entity = viewModel.repository.value.owner
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryInfoCell", forIndexPath: indexPath)
                cell.accessoryType = .None
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
                cell.textLabel?.text = "\(Octicon.GitCommit) Commits"
            case 1:
                cell.textLabel?.text = "\(Octicon.IssueOpened) Issues"
            case 2:
                cell.textLabel?.text = "\(Octicon.Tag) Releases"
            case 3:
                cell.textLabel?.text = "\(Octicon.Rss) Recent Activity"
            case 4:
                cell.textLabel?.text = "\(Octicon.Organization) Contributors"
            case 5:
                cell.textLabel?.text = "\(Octicon.GitPullRequest) PullRequests"
            default: break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryInfoCell", forIndexPath: indexPath)
            cell.textLabel?.text = viewModel.repository.value.defaultBranch!
            
            return cell
        default:
            return UITableViewCell()
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
