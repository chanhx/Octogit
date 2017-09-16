//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController {
    
    let viewModel = ExplorationViewModel()
    let headerView = SegmentHeaderView()
    
    var searchViewController = SearchViewController()
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self, optionsCount: 2, selectedRows: [0, 0])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        headerView.delegate = self
        headerView.title = .repositories
        headerView.titleLabel.delegate = self
        updateTitle()
        
        navigationItem.title = "Trending"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchViewController))
    }
    
    // MARK: SearchViewController
    
    func showSearchViewController() {
        
        searchViewController.hidesBottomBarWhenPushed = true
        searchViewController.navigationItem.setHidesBackButton(true, animated: false)
        searchViewController.activateSearchBar()
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromTop
        
        navigationController?.view.layer.add(transition, forKey: kCATransition)
		navigationController?.pushViewController(searchViewController, animated: false)
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch viewModel.type {
        case .repositories:
            let repo = self.viewModel.repoTVM.repositories.value[indexPath.row]
            let repoVC = RepositoryViewController.instantiateFromStoryboard()
            repoVC.viewModel = RepositoryViewModel(repo: repo.name)
            self.navigationController?.pushViewController(repoVC, animated: true)
        case .users:
            let user = viewModel.userTVM.users.value[indexPath.row]
            switch user.type! {
            case .user:
                let userVC = UserViewController.instantiateFromStoryboard()
                userVC.viewModel = UserViewModel(user)
                self.navigationController?.pushViewController(userVC, animated: true)
            case .organization:
                let orgVC = OrganizationViewController.instantiateFromStoryboard()
                orgVC.viewModel = OrganizationViewModel(user)
                self.navigationController?.pushViewController(orgVC, animated: true)
            }
        }
    }
}

extension ExplorationViewController: SegmentHeaderViewDelegate {
    
    func headerView(_ view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
        viewModel.type = title
        
        switch title {
        case .repositories:
            bindToRepoTVM()
        case .users:
            bindToUserTVM()
        }
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asDriver()
            .do(onNext: { [unowned self] in
                if $0.count <= 0 {
                    if let _ = self.viewModel.repoTVM.message {
                        self.show(statusType: .empty)
                    } else {
                        self.show(statusType: .loading)
                    }
                } else {
                    self.hide(statusType: .loading)
                }
            })
            .drive(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) {
                row, repo, cell in
                cell.configureCell(name: repo.name,
                                   description: repo.repoDescription,
                                   language: repo.language,
                                   stargazers: repo.stargazers,
                                   forks: repo.forks,
                                   periodStargazers: repo.periodStargazers)
            }
            .addDisposableTo(viewModel.repoTVM.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.users.asDriver()
            .do(onNext: { [unowned self] in
                if $0.count <= 0 {
                    if let _ = self.viewModel.userTVM.message {
                        self.show(statusType: .empty)
                    } else {
                        self.show(statusType: .loading)
                    }
                } else {
                    self.hide(statusType: .loading)
                }
            })
            .drive(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.userTVM.disposeBag)
    }
}

extension ExplorationViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        let time = viewModel.pickerVM.timeOptions[pickerView.selectedRows[0]].desc
        let language = viewModel.language.replacingOccurrences(of: "+", with: "\\+")
        
        headerView.titleLabel.setText(Octicon.flame.iconString("Trending for \(time) in \(viewModel.language)",
            iconSize: 18,
            iconColor: .red,
            attributes: [NSFontAttributeName: headerView.titleLabel.font]))
        
        headerView.titleLabel.addLink(URL(string: "Time")!, toText: time)
        headerView.titleLabel.addLink(URL(string: "Language")!, toText: language)
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        switch url.absoluteString {
        case "Time":
            pickerView.index = 0
        default:
            pickerView.index = 1
        }
        
        pickerView.show()
    }
}

extension ExplorationViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        let row0 = pickerView.selectedRows[0]
        let row1 = pickerView.selectedRows[1]
        
        viewModel.since = viewModel.pickerVM.timeOptions[row0].time
        viewModel.language = languagesArray[row1]

        viewModel.updateOptions()
        updateTitle()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerView.index == 0 ? 3 : languagesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerView.index == 0 ? viewModel.timeOptions[row] : languagesArray[row]
    }
}
