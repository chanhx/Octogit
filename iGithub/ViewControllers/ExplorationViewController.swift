//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController, UISearchControllerDelegate {
    
    let viewModel = ExplorationViewModel()
    let headerView = SegmentHeaderView()
    
    var searchController: UISearchController!
    var searchViewController = SearchViewController()
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self, optionsCount: 2)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        headerView.delegate = self
        headerView.title = .repositories
        headerView.titleLabel.delegate = self
        updateTitle()
        
        searchController = UISearchController(searchResultsController: searchViewController)
        
        searchController.searchResultsUpdater = searchViewController
        searchController.searchBar.delegate = searchViewController
        searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
    }
    
    // MARK: UISearchControllerDelegate
    
//    func didDismissSearchController(searchController: UISearchController) {
//        searchViewController clear search results
//    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch viewModel.type {
        case .repositories:
            let repo = self.viewModel.repoTVM.repositories.value[(indexPath as NSIndexPath).row]
            let repoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryVC") as! RepositoryViewController
            repoVC.viewModel = RepositoryViewModel(fullName: repo.name)
            self.navigationController?.pushViewController(repoVC, animated: true)
        case .users:
            let user = viewModel.userTVM.users.value[(indexPath as NSIndexPath).row]
            switch user.type! {
            case .User:
                let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserViewController
                userVC.viewModel = UserViewModel(user)
                self.navigationController?.pushViewController(userVC, animated: true)
            case .Organization:
                let orgVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrgVC") as! OrganizationViewController
                orgVC.viewModel = OrganizationViewModel(user)
                self.navigationController?.pushViewController(orgVC, animated: true)
            }
        }
    }
}

extension ExplorationViewController: SegmentHeaderViewDelegate {
    
    func headerView(_ view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
        switch title {
        case .repositories:
            bindToRepoTVM()
        case .users:
            bindToUserTVM()
        }
        
        viewModel.type = title
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "TrendingRepoCell", cellType: TrendingRepoCell.self)) {
                row, repo, cell in
                cell.configureCell(repo.name, description: repo.description, meta: repo.meta)
            }
            .addDisposableTo(viewModel.repoTVM.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.users.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.userTVM.disposeBag)
    }
}

extension ExplorationViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        let time = viewModel.pickerVM.timeOptions[pickerView.selectedRow[0]].desc
        headerView.titleLabel.text = "Trending for \(time) in \(viewModel.language)"
        headerView.titleLabel.addLink(URL(string: "Time")!, toText: time)
        
        let language = viewModel.language.replacingOccurrences(of: "+", with: "\\+")
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
        if let row0 = pickerView.tmpSelectedRow[0] {
            viewModel.since = viewModel.pickerVM.timeOptions[row0].time
        }
        if let row1 = pickerView.tmpSelectedRow[1] {
            viewModel.language = languagesArray[row1]
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerView.tmpSelectedRow[self.pickerView.index] = row
    }
}
