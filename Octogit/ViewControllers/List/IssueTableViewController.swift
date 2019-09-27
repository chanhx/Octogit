//
//  IssueTableViewController.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueTableViewController: BaseTableViewController {

    var viewModel: IssueTableViewModel! {
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
                .drive(tableView.rx.items(cellIdentifier: "IssueCell", cellType: IssueCell.self)) { row, element, cell in
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
        
        tableView.register(IssueCell.self, forCellReuseIdentifier: "IssueCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let issueVC = IssueViewController()
        issueVC.viewModel = viewModel.viewModelForIndex(indexPath.row)
        self.navigationController?.pushViewController(issueVC, animated: true)
    }

}
