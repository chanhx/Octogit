//
//  UserTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class UserTableViewController: BaseTableViewController {

    var viewModel: UserTableViewModel! {
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
                        self.show(statusType: .empty)
                    }
                })
                .bindTo(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            tableView.rx.itemSelected
                .map { indexPath in
                    self.viewModel.dataSource.value[indexPath.row]
                }
                .subscribe( onNext: {
                    switch $0.type! {
                    case .user:
                        let userVC = UserViewController.instantiateFromStoryboard()
                        userVC.viewModel = UserViewModel($0)
                        self.navigationController?.pushViewController(userVC, animated: true)
                    case .organization:
                        let orgVC = OrganizationViewController.instantiateFromStoryboard()
                        orgVC.viewModel = OrganizationViewModel($0)
                        self.navigationController?.pushViewController(orgVC, animated: true)
                    }
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }

}
