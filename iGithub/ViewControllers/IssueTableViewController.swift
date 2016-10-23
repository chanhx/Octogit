//
//  IssueTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueTableViewController: BaseTableViewController {

    var viewModel: IssueTableViewModel! {
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
//                    } else {
//                        self.hide(statusType: .empty(action))
                    }
                })
                .bindTo(tableView.rx.items(cellIdentifier: "IssueCell", cellType: IssueCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(IssueCell.self, forCellReuseIdentifier: "IssueCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchNextPage))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let issueVC = IssueViewController.instantiateFromStoryboard()
        issueVC.viewModel = viewModel.viewModelForIndex(indexPath.row)
        self.navigationController?.pushViewController(issueVC, animated: true)
    }

}
