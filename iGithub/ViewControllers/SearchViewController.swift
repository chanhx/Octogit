//
//  SearchViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/15/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: BaseTableViewController {
    
    let viewModel = SearchViewModel()
    let headerView = SegmentHeaderView()
    
    lazy var repoOptionsPickerView: OptionPickerView = OptionPickerView(delegate: self, optionsCount: 2)
    lazy var userOptionPickerView: OptionPickerView = OptionPickerView(delegate: self)
    
    init () {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        headerView.delegate = self
        headerView.title = .repositories
        headerView.titleLabel.delegate = self
        updateTitle()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        switch viewModel.option {
        case .repositories:
            let repo = self.viewModel.repoTVM.repositories.value[indexPath.row]
            let repoVC = RepositoryViewController.instantiateFromStoryboard()
            repoVC.viewModel = RepositoryViewModel(repo: repo)
            self.presentingViewController?.navigationController?.pushViewController(repoVC, animated: true)
        case .users:
            let user = viewModel.userTVM.users.value[indexPath.row]
            switch user.type! {
            case .user:
                let userVC = UserViewController.instantiateFromStoryboard()
                userVC.viewModel = UserViewModel(user)
                self.presentingViewController?.navigationController?.pushViewController(userVC, animated: true)
            case .organization:
                let orgVC = OrganizationViewController.instantiateFromStoryboard()
                orgVC.viewModel = OrganizationViewModel(user)
                self.presentingViewController?.navigationController?.pushViewController(orgVC, animated: true)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let query = searchController.searchBar.text, query.characters.count > 0 else {
            self.view.isHidden = false
            return
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let query = searchBar.text , query.characters.count > 0 {
            viewModel.search(query)
        }
    }
}

extension SearchViewController: SegmentHeaderViewDelegate {
    
    func headerView(_ view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
        switch title {
        case .repositories:
            bindToRepoTVM()
            viewModel.option = viewModel.options[0]
        case .users:
            bindToUserTVM()
            viewModel.option = viewModel.options[1]
        }
        
        updateTitle()
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) {
                row, repo, cell in
                cell.entity = repo
            }
            .addDisposableTo(viewModel.repoTVM.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.users.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.userTVM.disposeBag)
    }
}

extension SearchViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        let sortDescription = viewModel.titleVM.sortDescription(viewModel.option)
        switch viewModel.option {
        case .repositories(_, let language):
            headerView.titleLabel.text = "Sort: \(sortDescription) | Language: \(language)"
            headerView.titleLabel.addLink(URL(string: "ReposSort")!, toText: sortDescription)
            headerView.titleLabel.addLink(URL(string: "Language")!,
                                          toText: language.replacingOccurrences(of: "+", with: "\\+"))
        case .users(_):
            headerView.titleLabel.text = "Sort: \(sortDescription)"
            headerView.titleLabel.addLink(URL(string: "UsersSort")!, toText: sortDescription)
        }
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        switch url.absoluteString {
        case "ReposSort":
            repoOptionsPickerView.index = 0
            repoOptionsPickerView.show()
        case "Language":
            repoOptionsPickerView.index = 1
            repoOptionsPickerView.show()
        default:
            userOptionPickerView.index = 0
            userOptionPickerView.show()
        }
    }
    
    // MARK: picker view
}

extension SearchViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        if pickerView == repoOptionsPickerView {
            let row0 = pickerView.selectedRow[0]
            let row1 = pickerView.selectedRow[1]
            
            viewModel.option = .repositories(sort: viewModel.reposSortOptions[row0].option, language: languagesArray[row1])
        } else if pickerView == userOptionPickerView {
            let row = pickerView.selectedRow[0]
            viewModel.option = .users(sort: viewModel.usersSortOptions[row].option)
        }
        
        updateTitle()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch viewModel.option {
        case .repositories:
            return repoOptionsPickerView.index == 0 ? 4 : languagesArray.count
        case .users:
            return 4
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch viewModel.option {
        case .repositories:
            return repoOptionsPickerView.index == 0 ?
                viewModel.reposSortOptions.map {$0.desc} [row] :
                languagesArray[row]
        case .users:
            return viewModel.usersSortOptions.map {$0.desc} [row]
        }
    }
}
