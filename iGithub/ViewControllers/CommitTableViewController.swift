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
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: "CommitCell", cellType: CommitCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
//            tableView.rx.itemSelected
//                .map { indexPath in
//                    self.viewModel.dataSource.value[indexPath.row]
//                }
//                .subscribe( onNext: {
//                    
//                })
//                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(CommitCell.self, forCellReuseIdentifier: "CommitCell")
        
        viewModel.fetchData()
    }
    
}
