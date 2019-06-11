//
//  GistTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/4/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import RxSwift

class GistTableViewController: BaseTableViewController {
    
    var viewModel: GistTableViewModel! {
        didSet {
            viewModel.dataSource.asDriver()
                .skip(1)
                .do(onNext: { _ in
                    self.tableView.refreshHeader?.endRefreshing()
                    
                    self.viewModel.hasNextPage ?
                        self.tableView.refreshFooter?.endRefreshing() :
                        self.tableView.refreshFooter?.endRefreshingWithNoMoreData()
                })
                .drive(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistCell.self)) { row, element, cell in
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
        
        navigationItem.title = "Gist"
        tableView.register(GistCell.self, forCellReuseIdentifier: "GistCell")
        
        tableView.refreshHeader = RefreshHeader(target: viewModel, selector: #selector(viewModel.refresh))
        tableView.refreshFooter = RefreshFooter(target: viewModel, selector: #selector(viewModel.fetchData))
        
        tableView.refreshHeader?.beginRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let gistVC = GistViewController.instantiateFromStoryboard()
        gistVC.viewModel = GistViewModel(gist: viewModel.dataSource.value[indexPath.row])
        navigationController?.pushViewController(gistVC, animated: true)
    }
    
}
