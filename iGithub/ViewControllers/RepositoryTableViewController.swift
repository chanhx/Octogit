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
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { row, element, cell in
                    cell.shouldDisplayFullName = self.viewModel.shouldDisplayFullName
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            tableView.rx.itemSelected
                .map { indexPath in
                    self.viewModel.dataSource.value[indexPath.row]
                }
                .subscribe(onNext: { repo in
                    let repoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepositoryVC") as! RepositoryViewController
                    repoVC.viewModel = RepositoryViewModel(repo: repo)
                    self.navigationController?.pushViewController(repoVC, animated: true)
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        viewModel.fetchData()
    }

}
