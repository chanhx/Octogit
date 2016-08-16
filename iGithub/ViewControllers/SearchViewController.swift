//
//  SearchViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/15/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: BaseTableViewController, SegmentHeaderViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let viewModel = SearchViewModel()
    let headerView = SegmentHeaderView()
    
    init () {
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .OnDrag
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        tableView.registerClass(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        headerView.delegate = self
        headerView.title = .Repositories
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let query = searchController.searchBar.text
        
        if query == nil || query?.characters.count <= 0 {
            self.view.hidden = false
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let query = searchBar.text
        
        guard query != nil && query?.characters.count > 0 else {
            return
        }
        
        viewModel.search(query!)
    }
    
    // MARK: header view delegate
    
    func headerView(view: SegmentHeaderView, didSelectSegmentTitle title: SegmentTitle) {
        switch title {
        case .Repositories:
            bindToRepoTVM()
        case .Users:
            bindToUserTVM()
        }
        
        viewModel.type = title
    }
    
    func bindToRepoTVM() {
        viewModel.repoTVM.repositories.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("RepositoryCell", cellType: RepositoryCell.self)) {
                row, repo, cell in
                cell.entity = repo
            }
            .addDisposableTo(viewModel.disposeBag)
    }
    
    func bindToUserTVM() {
        viewModel.userTVM.users.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("UserCell", cellType: UserCell.self)) {
                row, user, cell in
                cell.entity = user
            }
            .addDisposableTo(viewModel.disposeBag)
    }
}
