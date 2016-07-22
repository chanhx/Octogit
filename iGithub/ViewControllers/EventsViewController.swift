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
    
    let viewModel = EventsTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.dataSource.asObservable()
            .skip(1)
            .subscribeNext { _ in
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            .addDisposableTo(viewModel.disposeBag)
        
        viewModel.fetchData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.value.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        cell.entity = viewModel.dataSource.value[indexPath.row]
        
        return cell
    }
}
