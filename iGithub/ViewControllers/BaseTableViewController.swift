//
//  BaseTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper

class BaseTableViewController: UITableViewController {
    
//    var viewModel: BaseTableViewModel
//    init(viewModel: BaseTableViewModel<Event>, style: UITableViewStyle = .Plain) {
//        self.viewModel = viewModel
//        super.init(style: style)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        viewModel.dataSource.asObservable().subscribeNext { _ in
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//            }
//            .addDisposableTo(viewModel.disposeBag)
//
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.viewModel = EventsTableViewModel()
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.dataSource.value.count
//    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
