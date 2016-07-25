//
//  EventsViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class EventsViewController: BaseTableViewController {
    
    var viewModel: EventsTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx_itemsWithCellIdentifier("EventCell", cellType: EventCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let repositoryVC = segue.destinationViewController as! RepositoryViewController
        repositoryVC.viewModel = viewModel.repositoryViewModelForIndex(tableView.indexPathForSelectedRow!.row)
    }
}
