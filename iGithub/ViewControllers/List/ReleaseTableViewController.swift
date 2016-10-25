//
//  ReleaseTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/6/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift

class ReleaseTableViewController: BaseTableViewController {
    
    var viewModel: ReleaseTableViewModel! {
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
                .drive(tableView.rx.items(cellIdentifier: "ReleaseCell", cellType: ReleaseCell.self)) { row, element, cell in
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
        
        navigationItem.title = "Release"
        tableView.register(ReleaseCell.self, forCellReuseIdentifier: "ReleaseCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
}
