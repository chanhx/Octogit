//
//  CommitTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/3/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import RxSwift

class CommitTableViewController: BaseTableViewController {
    
    var viewModel: CommitTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { [unowned self] _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .drive(tableView.rx.items(cellIdentifier: "CommitCell", cellType: CommitCell.self)) { row, element, cell in
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
        
        tableView.register(CommitCell.self, forCellReuseIdentifier: "CommitCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let commitVC = CommitViewController.instantiateFromStoryboard()
        commitVC.viewModel = viewModel.commitViewModel(forRow: indexPath.row)
        self.navigationController?.pushViewController(commitVC, animated: true)
    }
    
}
