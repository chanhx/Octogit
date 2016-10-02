//
//  PullRequestTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/2/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class PullRequestTableViewController: BaseTableViewController {
    
    var viewModel: PullRequestTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx.items(cellIdentifier: "IssueCell", cellType: IssueCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(IssueCell.self, forCellReuseIdentifier: "IssueCell")
        
        viewModel.fetchData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let pullRequestVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IssueVC") as! IssueViewController
        pullRequestVC.viewModel = viewModel.viewModelForIndex((indexPath as NSIndexPath).row)
        self.navigationController?.pushViewController(pullRequestVC, animated: true)
    }
    
}
