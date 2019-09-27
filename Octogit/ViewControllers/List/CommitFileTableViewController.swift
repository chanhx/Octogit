//
//  CommitFileTableViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 10/12/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import UIKit

class CommitFileTableViewController: BaseTableViewController {
    
    var viewModel: CommitFileTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .filter { $0.count > 0 }
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshingWithNoMoreData()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .drive(tableView.rx.items(cellIdentifier: "CommitFileCell", cellType: CommitFileCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .disposed(by: viewModel.disposeBag)
            
            viewModel.error.asDriver()
                .filter {
                    $0 != nil
                }
                .drive(onNext: { [unowned self] in
                    self.tableView.refreshHeader?.endRefreshing()
                    self.tableView.refreshFooter?.endRefreshing()
                    MessageManager.show(error: $0!)
                })
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Files"
        
        tableView.register(CommitFileCell.self, forCellReuseIdentifier: "CommitFileCell")
        
        if viewModel.dataSource.value.count <= 0 {
            tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
            tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))
            
            tableView.refreshHeader?.beginRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let fileVC = FileViewController()
        fileVC.viewModel = viewModel.fileViewModel(forRow: indexPath.row)
        self.navigationController?.pushViewController(fileVC, animated: true)
    }
}
