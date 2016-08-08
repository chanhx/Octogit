//
//  EventTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/21/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import TTTAttributedLabel

class EventTableViewController: BaseTableViewController, TTTAttributedLabelDelegate {
    
    var viewModel: EventTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx_itemsWithCellIdentifier("EventCell", cellType: EventCell.self)) { row, element, cell in
                    cell.entity = element
                    cell.titleLabel.delegate = self
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = viewModel.title
        
        viewModel.fetchData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let repositoryVC = segue.destinationViewController as! RepositoryViewController
        repositoryVC.viewModel = viewModel.repositoryViewModelForIndex(tableView.indexPathForSelectedRow!.row)
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        let webVC = WebViewController(url: url)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
}
