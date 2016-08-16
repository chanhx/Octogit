//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController, SegmentHeaderViewDelegate, UISearchControllerDelegate {
    
    let viewModel = ExplorationViewModel()
    let headerView = SegmentHeaderView()
    
    var searchController: UISearchController!
    var searchViewController = SearchViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        headerView.delegate = self
        headerView.title = .Repositories
        
        
        searchController = UISearchController(searchResultsController: searchViewController)
        
        searchController.searchResultsUpdater = searchViewController
        searchController.searchBar.delegate = searchViewController
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    // MARK: header
    
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
            .bindTo(tableView.rx_itemsWithCellIdentifier("TrendingRepoCell", cellType: TrendingRepoCell.self)) {
                row, repo, cell in
                cell.configureCell(repo.name, description: repo.description, meta: repo.meta)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
