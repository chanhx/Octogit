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
    
    @IBOutlet weak var starButton: IndicatorButton!
    @IBOutlet weak var forkButton: GradientButton!
    
    @IBOutlet weak var starsCountLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    
    let statusCell = StatusCell(name: "repository")
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self)
    
    var viewModel: RepositoryViewModel! {
        didSet {
            viewModel.repository.asDriver()
                .filter { [unowned self] _ in
                    return self.viewModel.isRepositoryLoaded
                }
                .drive(onNext: { [unowned self] repo in
                    self.tableView.reloadData()
                    
                    self.configureHeader(repo: repo)
                    self.sizeHeaderToFit(tableView: self.tableView)
                }).disposed(by: viewModel.disposeBag)
            
            viewModel.hasStarred.asDriver()
                .flatMap { Driver.from(optional: $0) }
                .drive(onNext: { [unowned self] in
                    self.updateStarStatus(hasStarred: $0)
                }).disposed(by: viewModel.disposeBag)
            
            viewModel.error
                .asDriver()
                .flatMap { Driver.from(optional: $0) }
                .drive(onNext: { [unowned self] in
                    MessageManager.show(error: $0)
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: viewModel.disposeBag)
            
        }
    }
    
    class func instantiateFromStoryboard() -> RepositoryViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryViewController") as! RepositoryViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(showActionSheet))
        
        iconLabel.text = ""
        titleLabel.text = viewModel.repository.value.name
        sizeHeaderToFit(tableView: self.tableView)
        
        starButton.setImage(Octicon.star.image(iconSize: 15, size: CGSize(width: 16, height: 15)), for: .normal)
        forkButton.setImage(Octicon.repoForked.image(iconSize: 15, size: CGSize(width: 13, height: 15)), for: .normal)
        
        starButton.addTarget(self, action: #selector(toggleStarring), for: .touchUpInside)
        
        starsCountLabel.layer.borderColor = UIColor(netHex: 0xd5d5d5).cgColor
        forksCountLabel.layer.borderColor = UIColor(netHex: 0xd5d5d5).cgColor
        
        viewModel.fetchRepository()
        viewModel.fetchBranches()
    }
    
    func configureHeader(repo: Repository) {
        iconLabel.text = repo.icon.rawValue
        updateTimeLabel.text = "Latest commit \(repo.pushedAt!.naturalString(withPreposition: true))"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        starsCountLabel.text = formatter.string(from: NSNumber(value: repo.stargazersCount!))
        forksCountLabel.text = formatter.string(from: NSNumber(value: repo.forksCount!))
    }
    
    @objc func toggleStarring() {
        starButton.showIndicator()
        viewModel.toggleStarring()
    }
    
    func updateStarStatus(hasStarred: Bool) {
		starButton.stopIndictorAnimation()
        starButton.setTitle(hasStarred ? "Unstar" : "Star", for: .normal)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        let stargazersCount = viewModel.repository.value.stargazersCount!
        
        guard hasStarred != viewModel.repository.value.hasStarred! else {
            starsCountLabel.text = formatter.string(from: NSNumber(value: stargazersCount))
			return
        }
        
        if hasStarred {
            starsCountLabel.text = formatter.string(from: NSNumber(value: stargazersCount + 1))
        } else {
            starsCountLabel.text = formatter.string(from: NSNumber(value: stargazersCount - 1))
        }
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
        let button = OptionButton(frame: CGRect(x: 15, y: 0, width: 120, height: 27))
        button.addTarget(self.pickerView, action: #selector(OptionPickerView.show), for: .touchUpInside)
        
        button.optionTitle = "Branch"
        button.choice = self.viewModel.repository.value.defaultBranch!
        
        let repositorySubject = self.viewModel.repository.asObservable().skipWhile { $0.defaultBranch == nil }
        let branchesLoadedSubject = self.viewModel.isBranchesLoaded.asObservable()
        
        Observable.combineLatest(repositorySubject, branchesLoadedSubject) { (repo, loaded) in
                (repo, loaded)
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .do(onNext: { [unowned self] (repo, loaded) in
                guard loaded else { return }
                self.viewModel.rearrangeBranches(withDefaultBranch: repo.defaultBranch!)
            })
            .map { $0.1 }
            .observeOn(MainScheduler.instance)
            .bind(to: button.rx.isEnabled)
            .disposed(by: self.viewModel.disposeBag)
        
        return button
    }()
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.sections[section] == .code ? header : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.sections[section] == .code {
            return 35
        } else if viewModel.sections[section] == .misc {
            return 10
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch viewModel.sections[indexPath.section] {
        case .info:
            switch viewModel.infoTypes[indexPath.row] {
            case .author:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                cell.entity = viewModel.repository.value.owner
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case .parent:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                let parent = viewModel.repository.value.parent!
                cell.textLabel?.attributedText = Octicon.repoClone.iconString(" \(parent.owner!) / \(parent.name!)", iconSize: 18, iconColor: .gray)
                return cell
            case .mirror:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                cell.accessoryType = .none
                cell.selectionStyle = .none
                let mirrorURL = viewModel.repository.value.mirrorURL!
                cell.textLabel?.attributedText = Octicon.mirror.iconString(" \(mirrorURL)", iconSize: 18, iconColor: .gray)
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
                let urlString = viewModel.repository.value.homepage!.host ?? viewModel.repository.value.homepage!.absoluteString
                cell.textLabel?.attributedText = Octicon.link.iconString(" \(urlString)", iconSize: 18, iconColor: .gray)
                return cell
            case .readme:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
                cell.textLabel?.textColor = UIColor(netHex: 0x333333)
                cell.textLabel?.attributedText = Octicon.book.iconString(" README", iconSize: 18, iconColor: .gray)
                return cell
            }
            
        case .code:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryInfoCell", for: indexPath)
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.fileCode.iconString(" Code", iconSize: 18, iconColor: .lightGray)
                cell.detailTextLabel?.text = viewModel.repository.value.primaryLanguage
            case 1:
                cell.textLabel?.attributedText = Octicon.history.iconString(" Commits", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }
            
            return cell
            
        case .misc:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoNumberCell", for: indexPath) as! InfoNumberCell
            
            switch viewModel.miscTypes[indexPath.row] {
            case .issues:
                cell.infoLabel.attributedText = Octicon.issueOpened.iconString(" Issues", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
                
                if let openIssuesCount = viewModel.repository.value.openIssuesCount, openIssuesCount > 0 {
                    cell.number = openIssuesCount
                }
            case .pullRequests:
                cell.infoLabel.attributedText = Octicon.gitPullrequest.iconString(" Pull requests", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
                
                if let openPRsCount = viewModel.repository.value.openPRsCount, openPRsCount > 0 {
                    cell.number = openPRsCount
                }
            case .releases:
                cell.infoLabel.attributedText = Octicon.tag.iconString(" Releases", iconSize: 18, iconColor: UIColor(netHex: 0x6CC644))
                
                if let releasesCount = viewModel.repository.value.releasesCount, releasesCount > 0 {
                    cell.number = releasesCount
                }
            case .contributors:
                cell.infoLabel.attributedText = Octicon.organization.iconString(" Contributors", iconSize: 18, iconColor: .lightGray)
            case .activity:
                cell.infoLabel.attributedText = Octicon.rss.iconString(" Recent activity", iconSize: 18, iconColor: .gray)
            }
            return cell
        
        case .loading:
            return statusCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch viewModel.sections[indexPath.section] {
        case .info:
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
            case .parent:
                navigationController?.pushViewController(URLRouter.viewController(forURL: viewModel.repository.value.parent!.url!), animated: true)
            case .homepage:
                navigationController?.pushViewController(URLRouter.viewController(forURL: viewModel.repository.value.homepage!), animated: true)
            case .readme:
                let fileVC = FileViewController()
                fileVC.viewModel = viewModel.readmeViewModel
                self.navigationController?.pushViewController(fileVC, animated: true)
            default:
                break
            }
        
        case .code:
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
        
        case .misc:
            switch viewModel.miscTypes[indexPath.row] {
            case .issues:
                let repo = viewModel.repository.value
                
                let openIssueTVC = IssueTableViewController()
                openIssueTVC.viewModel = IssueTableViewModel(repo: repo.nameWithOwner!)
                
                let closedIssueTVC = IssueTableViewController()
                closedIssueTVC.viewModel = IssueTableViewModel(repo: repo.nameWithOwner!, state: .closed)
                
                let issueSVC = SegmentViewController(viewControllers: [openIssueTVC, closedIssueTVC], titles: ["Open", "Closed"])
                issueSVC.navigationItem.title = "Issues"
                
                self.navigationController?.pushViewController(issueSVC, animated: true)
                
            case .pullRequests:
                let repo = viewModel.repository.value
                
                let openPullRequestTVC = PullRequestTableViewController()
                openPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo.nameWithOwner!)
                
                let closedPullRequestTVC = PullRequestTableViewController()
                closedPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo.nameWithOwner!, state: .closed)
                
                let pullRequestSVC = SegmentViewController(viewControllers: [openPullRequestTVC, closedPullRequestTVC], titles: ["Open", "Closed"])
                pullRequestSVC.navigationItem.title = "Pull requests"
                
                self.navigationController?.pushViewController(pullRequestSVC, animated: true)
                
            case .releases:
                let releaseTVC = ReleaseTableViewController()
                releaseTVC.viewModel = ReleaseTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(releaseTVC, animated: true)
                
            case .contributors:
                let memberTVC = UserTableViewController()
                memberTVC.viewModel = UserTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(memberTVC, animated: true)
                
            case .activity:
                let eventTVC = EventTableViewController()
                eventTVC.viewModel = EventTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(eventTVC, animated: true)
            }
            
        case .loading:
            break
        }
    }
}

extension RepositoryViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        viewModel.branch = viewModel.branches[pickerView.selectedRows[0]].name!
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

extension RepositoryViewController {
    
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
        let copyURLAction = UIAlertAction(title: "Copy URL", style: .default, handler: { _ in
            UIPasteboard.general.string = self.viewModel.htmlURL.absoluteString
        })
        let showOnGithubAction = UIAlertAction(title: "Show on GitHub", style: .default, handler: { _ in
            let webVC = WebViewController(url: self.viewModel.htmlURL)
            webVC.showNativeController = false
            self.navigationController?.pushViewController(webVC, animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
