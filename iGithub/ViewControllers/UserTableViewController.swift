//
//  UserTableViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/29/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

class UserTableViewController: BaseTableViewController {

    var viewModel: UserTableViewModel! {
        didSet {
            viewModel.dataSource.asObservable()
                .bindTo(tableView.rx_itemsWithCellIdentifier("UserCell", cellType: UserCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            tableView.rx_itemSelected
                .map {
                    self.viewModel.dataSource.value[$0.row]
                }.subscribeNext {
                    switch $0.type! {
                    case .User:
                        let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserVC") as! UserViewController
                        userVC.viewModel = UserViewModel($0)
                        self.navigationController?.pushViewController(userVC, animated: true)
                    case .Organization:
                        let orgVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrgVC") as! OrganizationViewController
                        orgVC.viewModel = OrganizationViewModel($0)
                        self.navigationController?.pushViewController(orgVC, animated: true)
                    }
                }.addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        viewModel.fetchData()
    }

}
