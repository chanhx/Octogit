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
                .bindTo(tableView.rx.items(cellIdentifier: "UserCell", cellType: UserCell.self)) { row, element, cell in
                    cell.entity = element
                }
                .addDisposableTo(viewModel.disposeBag)
            
            tableView.rx.itemSelected
                .map { indexPath in
                    self.viewModel.dataSource.value[indexPath.row]
                }
                .subscribe( onNext: {
                    switch $0.type! {
                    case .user:
                        let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserViewController
                        userVC.viewModel = UserViewModel($0)
                        self.navigationController?.pushViewController(userVC, animated: true)
                    case .organization:
                        let orgVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrgVC") as! OrganizationViewController
                        orgVC.viewModel = OrganizationViewModel($0)
                        self.navigationController?.pushViewController(orgVC, animated: true)
                    }
                })
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        viewModel.fetchData()
    }

}
