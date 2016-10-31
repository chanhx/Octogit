//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class IssueViewController: BaseTableViewController, WKNavigationDelegate {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var contentHeight = Variable<CGFloat>(0)
    
    let disposeBag = DisposeBag()
    var viewModel: IssueViewModel! {
        didSet {
            viewModel.fetchData()
            
            viewModel.dataSource.asDriver()
                .filter { $0.count > 0 }
                .drive(onNext: { [unowned self] _ in
                    self.tableView.reloadData()
                    
                    self.sizeHeaderToFit(tableView: self.tableView)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    class func instantiateFromStoryboard() -> IssueViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IssueViewController") as! IssueViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "#\(viewModel.issue.number!)"
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        configureHeader()
        
        sizeHeaderToFit(tableView: tableView)
        
        contentHeight.asDriver()
            .skip(1)
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] _ in
                self.tableView.reloadData()
                
                self.sizeHeaderToFit(tableView: self.tableView)
            })
            .addDisposableTo(disposeBag)
    }
    
    func configureHeader() {
        
        iconLabel.text = viewModel.issue.icon.rawValue
        iconLabel.textColor = viewModel.issue.iconColor
        
        titleLabel.text = viewModel.issue.title
        
        userAvatar.setAvatar(with: viewModel.issue.user?.avatarURL)
        
        let object = viewModel.issue.isPullRequest ? "pull request" : "issue"
        
        let attrInfo = NSMutableAttributedString(string: "\(viewModel.issue.user!) opened this \(object) \(viewModel.issue.createdAt!.naturalString)")
        attrInfo.addAttributes([
            NSForegroundColorAttributeName: UIColor(netHex: 0x555555),
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            ],
                              range: NSRange(location: 0, length: viewModel.issue.user!.login!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    // MARK: table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sectionType(for: section) {
        case .milestone:
            return "Milestone"
        case .asignees:
            return "Asignees"
        case .changes:
            return "Changes"
        case .timeline:
            if viewModel.dataSource.value.count > 0 {
                return "Comments"
            }
            return nil
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsIn(section: section)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sectionType(for: indexPath.section) {
        case .content:
            return contentHeight.value
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sectionType(for: indexPath.section) {
        case .content:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
            cell.webView.loadHTMLString(viewModel.contentHTML, baseURL: Bundle.main.resourceURL)
            cell.webView.navigationDelegate = self
            
            return cell
            
        case .milestone:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let title = viewModel.issue.milestone!.title!
            
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            cell.textLabel?.attributedText = Octicon.milestone.iconString(" \(title)", iconSize: 18)
            
            return cell
            
        case .asignees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            cell.accessoryType = .disclosureIndicator
            cell.entity = viewModel.issue.assignees![indexPath.row]
            
            return cell
            
        case .changes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = UIColor(netHex: 0x333333)
            
            let iconColor = UIColor(netHex: 0x4078C0)
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = Octicon.gitCommit.iconString(" Commits", iconSize: 18, iconColor: iconColor)
            case 1:
                cell.textLabel?.attributedText = Octicon.diff.iconString(" Files changed", iconSize: 18, iconColor: iconColor)
            default:
                break
            }
            
            return cell
            
        case .timeline:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.entity = viewModel.dataSource.value[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewModel.sectionType(for: indexPath.section) {
        case .asignees:
            let userVC = UserViewController.instantiateFromStoryboard()
            userVC.viewModel = UserViewModel(viewModel.issue.assignees![indexPath.row])
            navigationController?.pushViewController(userVC, animated: true)
        case .changes:
            switch indexPath.row {
            case 0:
                let commitTVC = CommitTableViewController()
                commitTVC.viewModel = CommitTableViewModel(repo: viewModel.repo, pullRequestNumber: viewModel.issue.number!)
                navigationController?.pushViewController(commitTVC, animated: true)
            case 1:
                let fileTVC = CommitFileTableViewController()
                fileTVC.viewModel = CommitFileTableViewModel(repo: viewModel.repo, pullRequestNumber: viewModel.issue.number!)
                navigationController?.pushViewController(fileTVC, animated: true)
            default:
                break
            }
        default: break
        }
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentHeight.value = webView.scrollView.contentSize.height
    }
}
