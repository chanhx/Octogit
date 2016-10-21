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
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self)
    
    var viewModel: RepositoryViewModel! {
        didSet {
            let repositorySubject = viewModel.repository.asObservable()
            let branchesSubject = viewModel.isBranchesLoaded.asObservable()
            
            Observable.combineLatest(repositorySubject, branchesSubject) {
                    ($0, $1)
                }.skipWhile({ (repo, _) in
                    repo.defaultBranch == nil
                })
                .subscribe(onNext: { (repo, isBranchLoaded) in
                    DispatchQueue.main.async {
                        
                        if isBranchLoaded {
                            self.viewModel.rearrangeBranches(withDefaultBranch: repo.defaultBranch!)
                        }
                        
                        self.tableView.reloadData()
                        
                        if repo.isPrivate! {
                            self.iconLabel.text = Octicon.lock.rawValue
                        } else {
                            self.iconLabel.text = repo.isAFork! ? Octicon.repoForked.rawValue : Octicon.repo.rawValue
                        }
                        self.updateTimeLabel.text = "Latest commit \(repo.pushedAt!.naturalString)"
                        
                        self.sizeHeaderToFit(tableView: self.tableView)
                    }
                }).addDisposableTo(viewModel.disposeBag)
        }
    }
    
    class func instantiateFromStoryboard() -> RepositoryViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryViewController") as! RepositoryViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconLabel.text = ""
        self.titleLabel.text = viewModel.repository.value.name
        self.sizeHeaderToFit(tableView: self.tableView)
        
        if !viewModel.isRepositoryLoaded {
            viewModel.fetchRepository()
        }
        viewModel.fetchBranches()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    lazy var header: UIView = {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35))
        header.addSubview(self.branchButton)
        
        return header
    }()
    
    lazy var branchButton: OptionButton = {
        let button = OptionButton(frame: CGRect(x: 12, y: 0, width: 120, height: 27))
        button.addTarget(self.pickerView, action: #selector(OptionPickerView.show), for: .touchUpInside)
        
        button.optionTitle = "Branch"
        button.choice = self.viewModel.repository.value.defaultBranch!
        
        self.viewModel.isBranchesLoaded.asObservable()
            .bindTo(button.rx.enabled)
            .addDisposableTo(self.viewModel.disposeBag)
        
        return button
    }()
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else {
            return nil
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 35
        } else if section == 2 {
            return 10
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard viewModel.isRepositoryLoaded else {
            return statusCell
        }
        
        switch indexPath.section {
        case 0:
            switch viewModel.infoTypes[indexPath.row] {
            case .author:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                cell.entity = viewModel.repository.value.owner
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case .description:
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                cell.textLabel?.text = viewModel.repository.value.repoDescription!
                return cell
            case .homepage:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                cell.textLabel?.attributedText = Octicon.link.iconString(" \(viewModel.repository.value.homepage!.host!)", iconSize: 18, iconColor: .gray)
                return cell
            case .readme:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                cell.textLabel?.attributedText = Octicon.book.iconString(" README", iconSize: 18, iconColor: .gray)
                return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.code.iconString(" Code", iconSize: 18, iconColor: .lightGray)
            case 1:
                cell.textLabel?.attributedText = Octicon.gitCommit.iconString(" Commits", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.issueOpened.iconString(" Issues", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 1:
                cell.textLabel?.attributedText = Octicon.gitPullrequest.iconString(" Pull requests", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 2:
                cell.textLabel?.attributedText = Octicon.tag.iconString(" Releases", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
            case 3:
                cell.textLabel?.attributedText = Octicon.organization.iconString(" Contributors", iconSize: 18, iconColor: .lightGray)
            case 4:
                cell.textLabel?.attributedText = Octicon.rss.iconString(" Recent activity", iconSize: 18, iconColor: .gray)
            default: break
            }
            return cell
        
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch indexPath.section {
        case 0:
            switch viewModel.infoTypes[indexPath.row] {
            case .author:
                switch viewModel.repository.value.owner!.type! {
                case .user:
                    let vc = UserViewController.instantiateFromStoryboard()
                    vc.viewModel = self.viewModel.ownerViewModel
                    self.navigationController?.pushViewController(vc, animated: true)
                case .organization:
                    let vc = OrganizationViewController.instantiateFromStoryboard()
                    vc.viewModel = (self.viewModel.ownerViewModel as! OrganizationViewModel)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .homepage:
                navigationController?.pushViewController(URLRouter.viewControllerForURL(viewModel.repository.value.homepage!), animated: true)
            case .readme:
                let fileVC = FileViewController()
                fileVC.viewModel = viewModel.readmeViewModel
                self.navigationController?.pushViewController(fileVC, animated: true)
            default:
                break
            }
        
        case 1:
            switch indexPath.row {
            case 0:
                let fileTableVC = FileTableViewController()
                fileTableVC.viewModel = viewModel.fileTableViewModel
                self.navigationController?.pushViewController(fileTableVC, animated: true)
                
            case 1:
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = viewModel.commitTableViewModel
                self.navigationController?.pushViewController(commitTVC, animated: true)
            default:
                break
            }
        
        case 2:
            switch indexPath.row {
            case 0:
                let repo = viewModel.repository.value
                
                let openIssueTVC = IssueTableViewController()
                openIssueTVC.viewModel = IssueTableViewModel(repo: repo)
                
                let closedIssueTVC = IssueTableViewController()
                closedIssueTVC.viewModel = IssueTableViewModel(repo: repo, state: .closed)
                
                let issueSVC = SegmentViewController(viewControllers: [openIssueTVC, closedIssueTVC], titles: ["Open", "Closed"])
                issueSVC.navigationItem.title = "Issues"
                
                self.navigationController?.pushViewController(issueSVC, animated: true)
                
            case 1:
                let repo = viewModel.repository.value
                
                let openPullRequestTVC = PullRequestTableViewController()
                openPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo)
                
                let closedPullRequestTVC = PullRequestTableViewController()
                closedPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo, state: .closed)
                
                let pullRequestSVC = SegmentViewController(viewControllers: [openPullRequestTVC, closedPullRequestTVC], titles: ["Open", "Closed"])
                pullRequestSVC.navigationItem.title = "Pull requests"
                
                self.navigationController?.pushViewController(pullRequestSVC, animated: true)
                
            case 2:
                let releaseTVC = ReleaseTableViewController()
                releaseTVC.viewModel = ReleaseTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(releaseTVC, animated: true)
                
            case 3:
                let memberTVC = UserTableViewController()
                memberTVC.viewModel = UserTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(memberTVC, animated: true)
                
            case 4:
                let eventTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventTVC") as! EventTableViewController
                eventTVC.viewModel = EventTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(eventTVC, animated: true)
            default:
                break
            }
            
        default:
            break
        }
    }
}

extension RepositoryViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        viewModel.branch = viewModel.branches[pickerView.selectedRow[0]].name!
        branchButton.choice = viewModel.branch
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.branches.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.branches[row].name!
    }
}
