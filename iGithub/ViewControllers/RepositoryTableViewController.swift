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
                .bindTo(tableView.rx_itemsWithCellIdentifier("RepositoryCell", cellType: RepositoryCell.self)) { row, element, cell in
                    cell.shouldDisplayFullName = self.viewModel.shouldDisplayFullName
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        viewModel.fetchData()
    }

}
