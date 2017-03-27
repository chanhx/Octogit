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
    
    let headerView = SegmentHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 90))
//    let headerView = SegmentHeaderView()
    
    lazy var repoOptionsPickerView: OptionPickerView = OptionPickerView(delegate: self, optionsCount: 2)
    lazy var userOptionPickerView: OptionPickerView = OptionPickerView(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0)

        tableView.tableHeaderView = headerView
        
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        headerView.delegate = self
        headerView.title = .repositories
        headerView.titleLabel.delegate = self
        updateTitle()
    }

    // MARK: - Table view data source
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 90
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return headerView
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewModel.searchObject {
        case .repository:
            let repo = viewModel.repoTVM.dataSource.value[indexPath.row]
            let repoVC = RepositoryViewController.instantiateFromStoryboard()
            repoVC.viewModel = RepositoryViewModel(repo: repo)
            self.presentingViewController?.navigationController?.pushViewController(repoVC, animated: true)
        case .user:
            let user = viewModel.userTVM.dataSource.value[indexPath.row]
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
            viewModel.search(query: query)
        }
    }
}

extension SearchViewController: SegmentHeaderViewDelegate {
    
    func headerView(_ view: SegmentHeaderView, didSelectSegmentTitle title: TrendingType) {
        switch title {
        case .repositories:
            viewModel.searchObject = .repository
            bindToRepoTVM()
        case .users:
            viewModel.searchObject = .user
            bindToUserTVM()
        }
        
        updateTitle()
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.dataSource.asDriver()
            .do(onNext: { [unowned self] in
                if $0.count <= 0 {
                    if self.viewModel.repoTVM.isLoading {
                        self.show(statusType: .loading)
                    } else {
                        self.show(statusType: .empty)
                    }
                } else {
                    self.hide(statusType: .loading)
                }
                
                self.viewModel.repoTVM.hasNextPage ?
                    self.tableView.refreshFooter?.endRefreshing() :
                    self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
            })
            .drive(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) {
                row, repo, cell in
                cell.configure(withRepository: repo)
            }
            .addDisposableTo(viewModel.repoTVM.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.dataSource.asDriver()
            .do(onNext: { [unowned self] in
                if $0.count <= 0 {
                    if self.viewModel.userTVM.isLoading {
                        self.show(statusType: .loading)
                    } else {
                        self.show(statusType: .empty)
                    }
                } else {
                    self.hide(statusType: .loading)
                }
                
                self.viewModel.userTVM.hasNextPage ?
                    self.tableView.refreshFooter?.endRefreshing() :
                    self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
            })
            .drive(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.userTVM.disposeBag)
    }
}

extension SearchViewController: TTTAttributedLabelDelegate {
    
    func updateTitle() {
        switch viewModel.searchObject {
        case .repository:
            let sortDescription = viewModel.repoTVM.sort.description
            let language = viewModel.repoTVM.language
            
            headerView.titleLabel.text = "\(sortDescription) in \(language)"
            headerView.titleLabel.addLink(URL(string: "ReposSort")!, toText: sortDescription)
            headerView.titleLabel.addLink(URL(string: "Language")!,
                                          toText: language.replacingOccurrences(of: "+", with: "\\+"))
        case .user:
            let sortDescription = viewModel.userTVM.sort.description
            
            headerView.titleLabel.text = sortDescription
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
            let row0 = pickerView.selectedRows[0]
            let row1 = pickerView.selectedRows[1]
            
            viewModel.repoTVM.sort = viewModel.repoTVM.sortOptions[row0]
            viewModel.repoTVM.language = languagesArray[row1]
        } else if pickerView == userOptionPickerView {
            let row = pickerView.selectedRows[0]
            
            viewModel.userTVM.sort = viewModel.userTVM.sortOptions[row]
        }
        
        updateTitle()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch viewModel.searchObject {
        case .repository:
            return repoOptionsPickerView.index == 0 ? 4 : languagesArray.count
        case .user:
            return 4
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch viewModel.searchObject {
        case .repository:
            return repoOptionsPickerView.index == 0 ?
                viewModel.repoTVM.sortOptions.map {$0.description} [row] :
                languagesArray[row]
        case .user:
            return viewModel.userTVM.sortOptions.map {$0.description} [row]
        }
    }
}
