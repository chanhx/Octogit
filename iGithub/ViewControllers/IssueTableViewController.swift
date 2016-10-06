//
//  IssueTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class IssueTableViewController: BaseTableViewController {

    var viewModel: IssueTableViewModel! {
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
        
        let issueVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IssueVC") as! IssueViewController
        issueVC.viewModel = viewModel.viewModelForIndex(indexPath.row)
        self.navigationController?.pushViewController(issueVC, animated: true)
    }

}
