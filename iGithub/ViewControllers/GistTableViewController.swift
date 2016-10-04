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
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Gist"
        tableView.register(GistCell.self, forCellReuseIdentifier: "GistCell")
        
        viewModel.fetchData()
    }
    
}
