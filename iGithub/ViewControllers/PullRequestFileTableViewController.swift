//
//  PullRequestFileTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class PullRequestFileTableViewController: BaseTableViewController {
    
    var viewModel: PullRequestFileTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .skip(1)
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshingWithNoMoreData()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .bindTo(tableView.rx.items(cellIdentifier: "PullRequestFileCell", cellType: PullRequestFileCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Files"
        
        tableView.register(PullRequestFileCell.self, forCellReuseIdentifier: "PullRequestFileCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let file = viewModel.dataSource.value[indexPath.row]
        
        let fileVC = FileViewController()
        fileVC.viewModel = FileViewModel(file: file)
        self.navigationController?.pushViewController(fileVC, animated: true)
    }
}
