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
            viewModel.repository.asObservable().subscribe(onNext: { repo in
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    if self.viewModel.repositoryLoaded {
                        if repo.isPrivate! {
                            self.iconLabel.text = Octicon.lock.rawValue
                        } else {
                            self.iconLabel.text = repo.isAFork! ? Octicon.repoForked.rawValue : Octicon.repo.rawValue
                        }
                        self.updateTimeLabel.text = "Latest commit \(repo.pushedAt!.naturalString)"
                    } else {
                        self.iconLabel.text = ""
                    }
                    self.titleLabel.text = repo.name
                    
                    self.sizeHeaderToFit(tableView: self.tableView)
                }
            }).addDisposableTo(viewModel.disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchRepository()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard viewModel.repositoryLoaded else {
            return statusCell
        }
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                cell.entity = viewModel.repository.value.owner
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case viewModel.numberOfRowsInSection(0) - 1:
                let cell = UITableViewCell()
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.attributedText = Octicon.book.iconString(" README", iconSize: 18, iconColor: .gray)
                return cell
            default:
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.text = viewModel.repository.value.repoDescription!
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.attributedText = Octicon.issueOpened.iconString(" Issues", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 1:
                cell.textLabel?.attributedText = Octicon.tag.iconString(" Releases", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 2:
                cell.textLabel?.attributedText = Octicon.rss.iconString(" Recent Activity", iconSize: 18, iconColor: .gray)
            case 3:
                cell.textLabel?.attributedText = Octicon.organization.iconString(" Contributors", iconSize: 18, iconColor: .lightGray)
            case 4:
                cell.textLabel?.attributedText = Octicon.gitPullrequest.iconString(" Pull Requests", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            default: break
            }
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.accessoryType = .disclosureIndicator
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.attributedText = Octicon.code.iconString(" Code", iconSize: 18, iconColor: .lightGray)
            case 1:
                cell.textLabel?.attributedText = Octicon.gitCommit.iconString(" Commits", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, 0):
            var vc: UIViewController
            
            switch viewModel.repository.value.owner!.type! {
            case .user:
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC")
                (vc as! UserViewController).viewModel = self.viewModel.ownerViewModel
            case .organization:
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrgVC")
                (vc as! OrganizationViewController).viewModel = (self.viewModel.ownerViewModel as! OrganizationViewModel)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case (0, viewModel.numberOfRowsInSection(0) - 1):
            let fileVC = FileViewController()
            fileVC.viewModel = FileViewModel(repository: viewModel.repository.value.fullName!)
            self.navigationController?.pushViewController(fileVC, animated: true)
        case (1, 0):
            let issueTVC = IssueTableViewController()
            issueTVC.viewModel = IssueTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(issueTVC, animated: true)
        case (1, 2):
            let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventTVC") as! EventTableViewController
            eventTVC.viewModel = EventTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(eventTVC, animated: true)
        case (1, 3):
            let memberTVC = UserTableViewController()
            memberTVC.viewModel = UserTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(memberTVC, animated: true)
        case (1, 4):
            let pullRequestTVC = PullRequestTableViewController()
            pullRequestTVC.viewModel = PullRequestTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(pullRequestTVC, animated: true)
        case (2, 0):
            let fileTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FileTVC") as! FileTableViewController
            fileTableVC.viewModel = viewModel.filesTableViewModel
            self.navigationController?.pushViewController(fileTableVC, animated: true)
        case (2, 1):
            let commitTVC = CommitTableViewController()
            commitTVC.viewModel = CommitTableViewModel(repo: viewModel.repository.value)
            self.navigationController?.pushViewController(commitTVC, animated: true)
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
