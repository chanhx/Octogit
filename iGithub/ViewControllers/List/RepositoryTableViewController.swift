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
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .do(onNext: { [unowned self] in
                    if $0.count <= 0 {
                        self.show(statusType: .empty)
                    } else {
                        self.hide(statusType: .empty)
                    }
                })
                .drive(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { row, element, cell in
                    cell.shouldDisplayFullName = self.viewModel.shouldDisplayFullName
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            viewModel.error.asDriver()
                .filter {
                    $0 != nil
                }
                .drive(onNext: { [unowned self] in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.tableView.refreshFooter?.endRefreshing()
                    MessageManager.show(error: $0!)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let repoVC = RepositoryViewController.instantiateFromStoryboard()
        repoVC.viewModel = viewModel.repoViewModel(forRow: indexPath.row)
        self.navigationController?.pushViewController(repoVC, animated: true)
    }

}
