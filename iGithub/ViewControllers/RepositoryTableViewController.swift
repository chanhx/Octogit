//
//  RepositoryTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/31/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class RepositoryTableViewController: BaseTableViewController {

    var viewModel: RepositoryTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .skip(1)
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .do(onNext: {
                    if $0.count <= 0 {
                        self.show(statusType: .empty(action: {}))
                    }
                })
                .bindTo(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { row, element, cell in
                    cell.shouldDisplayFullName = self.viewModel.shouldDisplayFullName
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            tableView.rx.itemSelected
                .map { indexPath in
                    self.viewModel.dataSource.value[indexPath.row]
                }
                .subscribe(onNext: { repo in
                    let repoVC = RepositoryViewController.instantiateFromStoryboard()
                    repoVC.viewModel = RepositoryViewModel(repo: repo)
                    self.navigationController?.pushViewController(repoVC, animated: true)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }

}
