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
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: "ReleaseCell", cellType: ReleaseCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Release"
        tableView.register(ReleaseCell.self, forCellReuseIdentifier: "ReleaseCell")
        
        viewModel.fetchData()
    }
    
}
