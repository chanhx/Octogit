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
    
    @IBOutlet weak var starButton: GradientButton!
    @IBOutlet weak var forkButton: GradientButton!
    
    @IBOutlet weak var starsCountLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    
    let statusCell = StatusCell(name: "repository")
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self)
    
    var viewModel: RepositoryViewModel! {
        didSet {
            let repoDriver = viewModel.repository.asDriver()
            let starDriver = viewModel.isStarring.asDriver()
            
            repoDriver
                .filter { $0.defaultBranch != nil }
                .drive(onNext: { [unowned self] repo in
                    self.tableView.reloadData()
                    
                    self.configureHeader(repo: repo)
                    self.sizeHeaderToFit(tableView: self.tableView)
                }).addDisposableTo(viewModel.disposeBag)
            
            Driver.combineLatest(repoDriver, starDriver) { repo, isStarring in
                    (repo, isStarring)
                }
                .filter { (repo, isStarring) in
                    repo.defaultBranch != nil && isStarring != nil
                }
                .drive(onNext: { [unowned self] (_, isStarring) in
                    self.starButton.isEnabled = true
                    self.starButton.setTitle(isStarring! ? "Unstar" : "Star", for: .normal)
                })
                .addDisposableTo(viewModel.disposeBag)
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
        
        starButton.addTarget(viewModel, action: #selector(viewModel.toggleStarring), for: .touchUpInside)
        
        starsCountLabel.layer.borderColor = UIColor(netHex: 0xd5d5d5).cgColor
        forksCountLabel.layer.borderColor = UIColor(netHex: 0xd5d5d5).cgColor
        
        if !viewModel.isRepositoryLoaded {
            viewModel.fetchRepository()
        }
        viewModel.checkIsStarring()
        viewModel.fetchBranches()
    }
    
    func configureHeader(repo: Repository) {
        if repo.isPrivate! {
            iconLabel.text = Octicon.lock.rawValue
        } else if repo.isAFork! {
            iconLabel.text = Octicon.repoForked.rawValue
        } else {
            iconLabel.text = Octicon.repo.rawValue
        }
        updateTimeLabel.text = "Latest commit \(repo.pushedAt!.naturalString(withPreposition: true))"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        starsCountLabel.text = formatter.string(from: NSNumber(value: repo.stargazersCount!))
        forksCountLabel.text = formatter.string(from: NSNumber(value: repo.forksCount!))
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
            .addDisposableTo(self.viewModel.disposeBag)
        
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
                cell.textLabel?.attributedText = Octicon.code.iconString(" Code", iconSize: 18, iconColor: .lightGray)
                cell.detailTextLabel?.text = viewModel.repository.value.language
            case 1:
                cell.textLabel?.attributedText = Octicon.gitCommit.iconString(" Commits", iconSize: 18, iconColor: .lightGray)
            default:
                break
            }
            
            return cell
            
        case .misc:
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
            switch indexPath.row {
            case 0:
                let repo = viewModel.repository.value
                
                let openIssueTVC = IssueTableViewController()
                openIssueTVC.viewModel = IssueTableViewModel(repo: repo.fullName!)
                
                let closedIssueTVC = IssueTableViewController()
                closedIssueTVC.viewModel = IssueTableViewModel(repo: repo.fullName!, state: .closed)
                
                let issueSVC = SegmentViewController(viewControllers: [openIssueTVC, closedIssueTVC], titles: ["Open", "Closed"])
                issueSVC.navigationItem.title = "Issues"
                
                self.navigationController?.pushViewController(issueSVC, animated: true)
                
            case 1:
                let repo = viewModel.repository.value
                
                let openPullRequestTVC = PullRequestTableViewController()
                openPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo.fullName!)
                
                let closedPullRequestTVC = PullRequestTableViewController()
                closedPullRequestTVC.viewModel = PullRequestTableViewModel(repo: repo.fullName!, state: .closed)
                
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
                let eventTVC = EventTableViewController()
                eventTVC.viewModel = EventTableViewModel(repo: viewModel.repository.value)
                self.navigationController?.pushViewController(eventTVC, animated: true)
            default:
                break
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
    
    func showActionSheet() {
        self.present(alertController, animated: true, completion: nil)
    }
}
