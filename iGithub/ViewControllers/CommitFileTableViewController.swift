//
//  CommitFileTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class CommitFileTableViewController: BaseTableViewController {
    
    var viewModel: CommitFileTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .skipWhile{ $0.count <= 0 }
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshingWithNoMoreData()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .bindTo(tableView.rx.items(cellIdentifier: "CommitFileCell", cellType: CommitFileCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Files"
        
        tableView.register(CommitFileCell.self, forCellReuseIdentifier: "CommitFileCell")
        
        if viewModel.dataSource.value.count <= 0 {
            tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
            tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
            
            tableView.refreshHeader?.beginRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let fileVC = FileViewController()
        fileVC.viewModel = viewModel.fileViewModel(forRow: indexPath.row)
        self.navigationController?.pushViewController(fileVC, animated: true)
    }
}
