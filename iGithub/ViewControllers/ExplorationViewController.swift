//
//  ExplorationViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseTableViewController, TrendingHeaderViewDelegate {
    
    let viewModel = ExplorationViewModel()
    let headerView = TrendingHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        navigationItem.title = "Trending Repositories"
        
        headerView.delegate = self
        headerView.type = .Repos
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    // MARK: header
    
    func headerView(view: TrendingHeaderView, didSelectTrendingType type: TrendingType) {
        switch type {
        case .Repos:
            bindToRepoTVM()
        case .Users:
            bindToUserTVM()
        }
        
        viewModel.type = type
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
